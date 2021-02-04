from clup_server import create_app
import argparse

parser = argparse.ArgumentParser(description='CLup Server')

parser.add_argument('--drop', action='store_true')
parser.add_argument('--dev', action='store_true')
parser.add_argument('--populate', action='store_true')
flags = parser.parse_args()

args = parser.parse_args()

app = create_app(dev=args.dev, drop_db=args.drop, populate=args.populate)

if __name__ == '__main__':
    app.run(host='0.0.0.0')


