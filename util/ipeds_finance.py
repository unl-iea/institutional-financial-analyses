# coding=utf-8

from sqlalchemy import Column, ForeignKey, Index, String, Integer, Date, Numeric

from base import Base

class IpedsFinance(Base):
    """ map to a table name in db """
    __tablename__ = "ipeds_finance"

    """ create columns """
    id = Column(Integer, primary_key = True)
    unitid = Column(Integer, nullable = False)
    date_key = Column(Date, ForeignKey('date_dimension.date_key'), nullable = False)
    finance_field_key = Column(String(16), ForeignKey('ipeds_finance_field_dimension.finance_field_key'), nullable = False)
    amount = Column(Numeric(12, 0), nullable = False, default = 0)

    """ Unique index constraint """
    __table_args__ = (Index('idx_ipeds_finance_keys',
                            'unitid',
                            'date_key',
                            'finance_field_key',
                            unique = True), )

    def __init__(self, unitid, date_key, finance_field_key, amount):
        """ method for instantiating object """
        self.unitid = unitid
        self.date_key = date_key
        self.finance_field_key = finance_field_key
        self.amount = amount

    def __repr__(self):
        """ produces human-readable object call """
        return (
            f'{self.__class__.__name__}('
            f'unitid={self.unitid!r}, '
            f'date_key={self.date_key!r}, '
            f'finance_field_key={self.finance_field_key!r}, '
            f'amount={self.amount!r})')
