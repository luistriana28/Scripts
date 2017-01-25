import csv
import odoorpc
import logging
import sys
import traceback

odoo = odoorpc.ODOO('localhost', port=32769)
odoo.login('erp-carbotecnia-info', 'admin', 'carbotecnia')

with open('productos.csv') as csvfile:
    reader = csv.DictReader(csvfile)
    count = 1
    for row in reader:
        print count
        count += 1

        try:
            odoo.execute('mrp.bom', 'create', {
                    'id': row['id'],
                    'product_tmpl_id': row['product_tmpl_id'],
                    'product_qty': row['product_qty'],
                    'product_uom_id': row['product_uom'],
                    'code': row['code'],
                    'type': row['normal'],
                    'bom_line_ids': [
                        'product_id': row['bom_line_ids/product_id/id'],
                        'product_qty': row[' bom_line_ids/product_qty'],
                        'product_uom': row['bom_line_ids/product_uom'],
                        'product_efficiency': row['bom_line_ids/product_efficiency']
                    ],})

        except:
            exc_type, exc_value, exc_traceback = sys.exc_info()
            l = traceback.format_exception(
                exc_type, exc_value, exc_traceback)
            print '*' * 20 + str('Se creo mal el producto')
            logging.debug(l)
            logging.debug("\n")
