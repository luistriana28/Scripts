import odoorpc

# Prepare the connection to the server
odoo = odoorpc.ODOO('localhost', port=8069)

# Check available databases
print(odoo.db.list())

# Login
odoo.login('db_name', 'user', 'passwd')

# Current user
user = odoo.env.user
print(user.name)            # name of the user connected
print(user.company_id.name) # the name of its company

# Simple 'raw' query
user_data = odoo.execute('res.users', 'read', [user.id])
print(user_data)

# Use all methods of a model
if 'sale.order' in odoo.env:
    Order = odoo.env['account.invoice.line']
    order_ids = Order.search(['quantity_unsigned', '=', 0])
    for order in Order.browse(order_ids):
        print(order.quantity_unsigned)
        products = [line.product_id.name for line in order.order_line]
        print(products)

# Update data through a record
user.name = "Brian Jones"


import odoorpc
odoo = odoorpc.ODOO(timeout=4000000)
odoo.login('soluziono', 'admin', 'S0l4z10n0')
ilines = odoo.env['account.invoice.line'].search([])
lines = odoo.env['account.invoice.line'].browse(ilines)
for x in lines:
    if x.invoice_id.type == 'out_invoice':
        x.quantity_unsigned = x.quantity * 1
    if x.invoice_id.type == 'out_refund':
        x.quantity_unsigned = x.quantity * -1
    if x.invoice_id.type == 'in_invoice':
        x.quantity_unsigned = x.quantity * -1
    if x.invoice_id.type == 'in_refund':
        x.quantity_unsigned = x.quantity * 1
    print x.name
