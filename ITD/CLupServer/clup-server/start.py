from clup_server import create_app

app = create_app(dev=True)

if __name__ == '__main__':
    app.run(host='0.0.0.0')