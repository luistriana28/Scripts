import csv
import oerplib

oerp = oerplib.OERP('web page', protocol='xmlrpc', port=80)
user = oerp.login('username', 'password', 'web page')

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
                'type': row['type'],
                'list_price': row['list_price'],
                'default_code': row['default_code'],
                'standard_price': row['standard_price']})
