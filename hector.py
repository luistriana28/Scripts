import odoorpc
import progressbar
import logging
import sys
import traceback
odoo = odoorpc.ODOO('localhost', port=8069)
odoo2 = odoorpc.ODOO('localhost', port=8069)
odoo.login('test', 'admin', 'admin')
odoo2.login('mtnet', 'admin', 'admin')
product_obj = odoo.env['product.template']
product_ids = product_obj.search([])
products = product_obj.browse(product_ids)
logging.basicConfig(filename="product.log", level=logging.DEBUG)
count = 0
with progressbar.ProgressBar(max_value=len(products)) as bar:
    for product in products:
        count += 1
        bar.update(count)
        uom_id = odoo2.env['product.uom'].search([('name', '=', product.uom_id.name)])
        uom_po_id = odoo2.env['product.uom'].search([('name', '=', product.uom_po_id.name)])
        routes = []
        for route in product.route_ids:
            route_id = odoo2.env['stock.location.route'].search([('name', '=', route.name)])
            routes.append(route_id[0])
        categ_id = odoo2.env['product.category'].search([('name', '=', product.categ_id.name)])
        try:
            odoo2.execute('product.template', 'create', {
                'name': product.name,
                'sale_ok': product.sale_ok,
                'purchase_ok': product.purchase_ok,
                'type': product.type,
                'default_code': product.default_code,
                'barcode': product.barcode,
                'invoice_policy': product.invoice_policy,
                'list_price': product.list_price,
                'standard_price': product.standard_price,
                'uom_id': uom_id[0],
                'uom_po_id': uom_po_id[0],
                'purchase_method': product.purchase_method,
                'route_ids': ([(6, 0, routes)] if routes else False),
                'categ_id': 1,
                'warranty': product.warranty,
                'sale_delay': product.sale_delay,
                'description_sale': product.description_sale,
                'description_purchase': product.description_purchase,
                'description_picking': product.description_picking,
                })
        except:
            exc_type, exc_value, exc_traceback = sys.exc_info()
            lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
            print '*' * 20 + product.name
            logging.debug(lines)
