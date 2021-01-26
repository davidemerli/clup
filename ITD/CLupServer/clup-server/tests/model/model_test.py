from model import CLupUser
import sqlalchemy
from sqlalchemy.orm import sessionmaker

def test():
    db = sqlalchemy.create_engine('postgresql://postgres:postgres@127.0.0.1:5432/CLup', echo=True)
    Session = sessionmaker(bind=db)
    session = Session()
    test_user = CLupUser(name='marcantonio', email='marc@ntonio.it', pwd='Sussas',store_op= False)
    session.add(test_user)
    userq = session.query(CLupUser).filter_by(name='marcanzio').first()
    print(userq)
    userq = session.query(CLupUser).filter_by(name='marcantonio').first()
    print(userq)
    userg = session.query(CLupUser).filter_by(email='psg@psg.psg').all()
    print(userg)