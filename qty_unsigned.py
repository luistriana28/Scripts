import odoorpc
import progressbar
odoo = odoorpc.ODOO(timeout=4000000000)
odoo.login('soluziono', 'admin', 'S0l4z10n0')
ilines = odoo.env['account.invoice.line'].search([(
    'quantity_unsigned', '<=', 0)])
lines = odoo.env['account.invoice.line'].browse(ilines)
count = 0
with progressbar.ProgressBar(max_value=len(lines)) as bar:
    for x in lines:
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
