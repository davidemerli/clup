from clup_server import create_app

def run_app(populate=False):
    app = create_app(populate=populate)
    return app