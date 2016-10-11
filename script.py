import csv
import oerplib

oerp = oerplib.OERP('199.19.103.74', protocol='xmlrpc', port=8069)
user = oerp.login('admin', 'admin', 'PruebasAlan')

with open('productos.csv') as csvfile:
    reader = csv.DictReader(csvfile)
    count = 1
    for row in reader:
        print count
        count += 1
        oerp.create(
            'product.product', {
                'name': row['name'],
                'sale_ok': row['sale_ok'],
                'purchase_ok': row['purchase_ok'],
                'type': row['type'],
                'list_price': row['list_price'],
                'default_code': row['default_code'],
                'invoice_policy': row['invoice_policy'],
                'uom_id': row['uom_id'],
                'uom_po_id': row['uom_po_id'],
                'purchase_method': row['purchase_method'],
                'route_ids': row['route_ids'],
                'categ_id': row['categ_id'],
                'warranty': row['warranty'],
                'produce_delay': row['produce_delay'],
                'sale_delay': row['sale_delay'],
                'description_sale': row['description_sale'],
                'description_purchase': row['description_purchase'],
                'description_picking': row['description_picking'],
                'standard_price': row['standard_price']})
