# coding=utf-8

from sqlalchemy import Column, String

from base import Base

class IpedsFinanceFieldDimension(Base):
    """ map to a table name in db """
    __tablename__ = "ipeds_finance_field_dimension"

    """ create columns """
    finance_field_key = Column(String(16), primary_key = True)
    finance_field = Column(String(255), nullable = False)

    def __init__(self, finance_field_key, finance_field):
        """ method for instantiating object """
        self.finance_field_key
        self.finance_field = finance_field

    def __repr__(self):
        """ produces human-readable object call """
        return (
            f'{self.__class__.__name__}('
            f'finance_field_key={self.finance_field_key!r}, '
            f'finance_field={self.finance_field})'
            )
