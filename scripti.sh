import odoorpc
import progressbar
odoo = odoorpc.ODOO()
odoo.login('localhost', 'admin', 'admin')
moves = odoo.env['account.payment'].search(['state', '=', 'done'])
moves_browse = odoo.env['stock.move'].browse(moves)
with progressbar.ProgressBar(max_value=len(packages)) as bar:
    valued_quantity = 0
    valued_move_lines = filter(lambda ml: not ml.location_id._should_be_valued() and ml.location_dest_id._should_be_valued() and not ml.owner_id), self.move_lines_ids)
        for valued_move_line in valued_move_lines:
        valued_quantity += valued_move_line.product_uom_id._compute_quantity(valued_move_line.qty_done, self.product_id.uom_id)



import odoorpc
import progressbar
odoo=odoorpc.ODOO()
odoo.login('test', 'admin', 'admin')
count=0
ilines=odoo.env['account.invoice.line'].search([('quantity_unsigned', '<=', 0)])
with progressbar.ProgressBar(max_value=len(ilines)) as bar:
    for x in ilines:
        if x.invoice_id.type == 'out_invoice':
            x.quantity_unsigned = x.quantity * 1
        if x.invoice_id.type == 'out_refund':
            x.quantity_unsigned = x.quantity * -1
        if x.invoice_id.type == 'in_invoice':
            x.quantity_unsigned = x.quantity * -1
        if x.invoice_id.type == 'in_refund':
            x.quantity_unsigned = x.quantity * 1
        count += 1
        bar.update(count)




print 'Borrando TIMP y CAMB'

timp_exch_move_ids = odoo.env['account.move'].search([
    ('journal_id', 'in', [4, 77])])
timp_exch_moves = odoo.env['account.move'].browse(timp_exch_move_ids)

count = 0
with progressbar.ProgressBar(max_value=len(timp_exch_move_ids)) as bar:
    for te_move in timp_exch_moves:
        if te_move.state == 'posted':
            te_move.button_cancel()
        try:
            te_move.line_ids.remove_move_reconcile()
            te_move.unlink()
        except:
            message = 'move: %s' % str(te_move.id)
            logging.debug(message)
            exc_type, exc_value, exc_traceback = sys.exc_info()
            lines = traceback.format_exception(
                exc_type, exc_value, exc_traceback)
            for bug in lines:
                logging.debug(bug)
        count += 1
        bar.update(count)



move_ids = odoo.env['account.move'].search([
    ('journal_id.type', 'in', ['bank', 'cash'])])
count = 0
processed_payments = []
# Revalua Pagos
print 'Revaluando pagos'
with progressbar.ProgressBar(max_value=len(move_ids)) as bar:
    for move in move_ids:
        move = odoo.env['account.move'].browse(move)
        new_lines = []
        total_debit = 0
        total_credit = 0
        diff_line = False
        usd_bank = False
        balance = 0
        if move.journal_id.currency_id:
            usd_bank = True
        for ml in move.line_ids:
            # user_type_id = 3 = Bank and Cash
            # Bank line MXN
            if ml.account_id.user_type_id.id == 3 and not usd_bank:
                total_debit = ml.debit if ml.debit > 0 else 0
                total_credit = ml.credit if ml.credit > 0 else 0
            # Bank line USD
            elif (ml.account_id.user_type_id.id == 3 and usd_bank and
                    ml.currency_id):
                new_amount = usd_to_mxn(ml.amount_currency, move.date)
                total_debit += new_amount if new_amount > 0 else 0
                total_credit += abs(new_amount) if new_amount < 0 else 0
                new_lines.append((1, ml.id, {
                    'debit': new_amount if new_amount > 0 else 0,
                    'credit': abs(new_amount) if new_amount < 0 else 0,
                    }))
            elif ml.account_id.reconcile and usd_bank and ml.currency_id:
                # Invoice USD -> Payment USD
                if ml.id in payment_relation:
                    new_amount = usd_to_mxn(ml.amount_currency, move.date)
                    total_debit += new_amount if new_amount > 0 else 0
                    total_credit += abs(new_amount) if new_amount < 0 else 0
                    new_lines.append((1, ml.id, {
                        'debit': new_amount if new_amount > 0 else 0,
                        'credit': abs(new_amount) if new_amount < 0 else 0,
                        }))
                # Invoice MXN -> Payment USD
                else:
                    amount_currency = mxn_to_usd(ml.balance, move.date)
                    total_debit += ml.balance if ml.balance > 0 else 0
                    total_credit += abs(ml.balance) if ml.balance < 0 else 0
                    new_lines.append((1, ml.id, {
                        'amount_currency': amount_currency,
                        }))
            # Invoice USD -> Payment MXN
            elif not usd_bank and ml.account_id.reconcile and ml.currency_id:
                amount_currency = mxn_to_usd(ml.balance, ml.date)
                total_debit += ml.balance if ml.balance > 0 else 0
                total_credit += abs(ml.balance) if ml.balance < 0 else 0
                new_lines.append((1, ml.id, {
                    'amount_currency': amount_currency,
                    }))
            # 457 Utilidad por Diferencia en cobros y pagos
            # 556 Perdida por Diferencia en cobros y pagos
            elif ml.account_id.id in [457, 556]:
                diff_line = ml
            else:
                total_debit += ml.debit if ml.debit > 0 else 0
                total_credit += ml.credit if ml.credit > 0 else 0
        balance = round(total_debit - total_credit, 2)
        if diff_line:
            amount_currency = mxn_to_usd(balance, move.date)
            new_lines.append((1, diff_line.id, {
                'debit': abs(balance) if balance < 0 else 0,
                'credit': balance if balance > 0 else 0,
                'amount_currency': -amount_currency,
                'currency_id': 3,
                }))
        if not new_lines:
            processed_payments.append(move.id)
            continue
        if balance != 0 and not diff_line:
            if new_lines[0][2]['debit'] > 0:
                if balance > 0:
                    new_lines[0][2]['debit'] -= balance
                else:
                    new_lines[0][2]['debit'] += abs(balance)
                new_lines[0][2]['debit'] = round(new_lines[0][2]['debit'], 2)
            else:
                if balance > 0:
                    new_lines[0][2]['credit'] += balance
                else:
                    new_lines[0][2]['credit'] -= abs(balance)
                new_lines[0][2]['credit'] = round(new_lines[0][2]['credit'], 2)
        try:
            move.button_cancel()
            move.write({'line_ids': new_lines})
            move.post()
            processed_payments.append(move.id)
        except:
            message = 'move: %s' % str(move.id)
            logging.debug(message)
            exc_type, exc_value, exc_traceback = sys.exc_info()
            lines = traceback.format_exception(
                exc_type, exc_value, exc_traceback)
            for bug in lines:
                logging.debug(bug)
        count += 1
        bar.update(count)

logging.debug("Processed Payments")
logging.debug(processed_payments)

reconciled_moves = []
# Reconciliar Pagos con Facturas
print 'Reconciliando Pagos con Facturas'
logging.debug('Reconciliando Pagos con Facturas')
with progressbar.ProgressBar(max_value=len(reconciled_ids)) as bar:
    for rec_moves in reconciled_ids:
        moves = odoo.env['account.move.line'].browse(rec_moves)
        try:
            moves.reconcile()
            reconciled_moves.append(moves.ids)
        except:
            logging.debug('move_lines: ')
            logging.debug(rec_moves)
            exc_type, exc_value, exc_traceback = sys.exc_info()
            lines = traceback.format_exception(
                exc_type, exc_value, exc_traceback)
            for bug in lines:
                logging.debug(bug)
        count += 1
        bar.update(count)

logging.debug("Processed Payments")
logging.debug(reconciled_moves)

odoo.env.user.company_id.period_lock_date = period_lock
odoo.env.user.company_id.fiscalyear_lock_date = fiscal_year_lock




import odoorpc
import progressbar
odoo = odoorpc.ODOO(timeout=1232131)
odoo.login('test', 'admin', 'admin')
brand_ids = odoo.env['product.brand'].search([])
brands = odoo.env['product.brand'].browse(brand_ids)
count = 0
bar = progressbar.ProgressBar(max_value=len(brands)).start()
import ipdb; ipdb.set_trace()
for brand in brands:
    brand_id = odoo.execute('account.analytic.tag', 'create', {
        'name': brand.name,
        'percentage': 100,
    'usage': 'brand',
    })
    brand.account_analytic_tag_id = brand_id
    count += 1
    bar.update(count)


import progressbar
import psycopg2
import odoorpc

conn_string = "dbname='test' user='admin' password='admin'"
conn = psycopg2.connect(conn_string)
cr = conn.cursor()
odoo = odoorpc.ODOO()
odoo.login('test', password='admin')

cr.execute(
    """SELECT inv.id, inv.move_id, inv.number, inv.currency_id
       FROM account_invoice inv
       JOIN account_journal aj
           ON aj.account_analytic_id = inv.account_analytic_id
       WHERE inv.date >= '2018-01-01'
            AND aj.account_analytic_id IN (12, 22, 25)
            AND state IN ('open', 'paid')
       ORDER BY inv.id""")
invoices = cr.fetchall()
count = 0
with progressbar.ProgressBar(max_value=len(invoices)) as bar:
    for rec in invoices:
        cr.execute("""
            SELECT id, price_subtotal FROM account_invoice_line
            WHERE invoice_id = %s
            """ % (rec[0]))
        lines = cr.fetchall()
        for line in lines:
            if rec[3] == 34:
                cr.execute("""
                    SELECT analytic_account_id
                    FROM account_move_line
                    WHERE move_id = %s AND balance = %s """, (
                        rec[1], float(line[1])))
            else:
                cr.execute("""
                    SELECT analytic_account_id
                    FROM account_move_line
                    WHERE move_id = %s AND amount_currency = %s """, (
                        rec[1], float(line[1])))
            account_analytic_id = cr.fetchone()
            if not account_analytic_id:
                print("Error Invoice: %s line: %s" % (rec[2], line[1]))
                count += 1
                bar.update(count)
                continue
            cr.execute("""
                UPDATE account_invoice_line
                SET account_analytic_id = %s
                WHERE id = %s""", (account_analytic_id[0], line[0]))
            conn.commit()
        count += 1
        bar.update(count)


import progressbar
import psycopg2

conn_string = "dbname='test' user='admin' password='admin'"
conn = psycopg2.connect(conn_string)
cr = conn.cursor()
cr.execute(
    """SELECT tax.cash_basis_account
       FROM account_tax tax
       WHERE tax.cash_basis_account IS NOT NULL""")
tax_accounts = [x[0] for x in cr.fetchall()]
cr.execute(
    """SELECT currency_exchange_journal_id
       FROM res_company
       WHERE currency_exchange_journal_id IS NOT NULL""")
exchange_journals = [x[0] for x in cr.fetchall()]
cr.execute("""
    SELECT aml.id, aml.account_id, ABS(aml.balance), am.id, am.name
    FROM account_move_line aml
    JOIN account_move am ON am.id = aml.move_id
    WHERE aml.account_id IN %s
        AND aml.date BETWEEN '2018-07-01' AND '2018-08-31'
        AND aml.journal_id IN %s
""" % (tuple(tax_accounts), tuple(exchange_journals)))
amls = cr.fetchall()
count = 0
print("Inverting the accounts of the tax moves in exchange journal entries")
with progressbar.ProgressBar(max_value=len(amls)) as bar:
    for rec in amls:
        cr.execute("""
            SELECT id, account_id, analytic_account_id
            FROM account_move_line
            WHERE move_id = %s
                AND ABS(balance) = %s
                AND account_id NOT IN %s""" % (
                    rec[3], rec[2], tuple(tax_accounts)))
        aml = cr.fetchall()
        if len(aml) > 1 or not aml:
            print(rec[4])
            count += 1
            bar.update(count)
            continue
        cr.execute("""
            UPDATE account_move_line
            SET account_id = %s
            WHERE id = %s""" % (
                rec[1], aml[0][0]))
        conn.commit()
        cr.execute("""
            UPDATE account_move_line
            SET account_id = %s
            WHERE id = %s""" % (
                aml[0][1], rec[0]))
        conn.commit()
        if aml[0][2] is None:
            print(rec[4])
            count += 1
            bar.update(count)
            continue
        cr.execute("""
            UPDATE account_move_line
            SET analytic_account_id = %s
            WHERE id = %s""" % (
                aml[0][2], rec[0]))
        conn.commit()
        cr.execute("""
            UPDATE account_move_line
            SET analytic_account_id = NULL
            WHERE id = %s""" % (aml[0][0]))
        conn.commit()
        # cr.execute("""
        #     SELECT amount
        #     FROM account_analytic_line
        #     WHERE move_id = %s
        #     """ % (aml[0][0]))
        # amount = cr.fetchone()
        # cr.execute("""
        #     UPDATE account_analytic_line
        #     SET move_id = %s amount = %s
        #     WHERE id = %s""" % (
        #     rec[0], -amount[0], aml[0][0]))
        # conn.commit()
        count += 1
        bar.update(count)
