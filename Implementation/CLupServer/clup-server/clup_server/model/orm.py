from sqlalchemy.schema import CreateColumn
from sqlalchemy.ext.compiler import compiles


# Replace deprecated Serial Generation with Identity
@compiles(CreateColumn, 'postgresql')
def use_identity(element, compiler, **kw):
    text = compiler.visit_create_column(element, **kw)
    text = text.replace('SERIAL', 'INTEGER GENERATED BY DEFAULT AS IDENTITY')
    return text
