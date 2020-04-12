# coding=utf-8

from sqlalchemy import Column, ForeignKey, Index, String, Integer, Date, Numeric

from base import Base

class IpedsFallEnrollment(Base):
    """ map to a table name in db """
    __tablename__ = "ipeds_fall_enrollment"

    """ create columns """
    id = Column(Integer, primary_key = True)
    unitid = Column(Integer, nullable = False)
    date_key = Column(Date, ForeignKey('date_dimension.date_key'), nullable = False)
    time_status = Column(String(16), nullable = False)
    career_level = Column(String(16), nullable = False)
    degree_seeking = Column(String(20), nullable = False)
    continuation_type = Column(String(16), nullable = False)
    demographic_key = Column(String(5), ForeignKey('ipeds_demographic_dimension.demographic_key'), nullable = False)
    headcount = Column(Integer, nullable = False, default = 0)

    """ Unique index constraint """
    __table_args__ = (Index('idx_ipeds_fall_enrollment_keys',
                            'unitid',
                            'date_key',
                            'time_status',
                            'career_level',
                            'degree_seeking',
                            'continuation_type',
                            'demographic_key',
                            unique = True), )

    def __init__(self, unitid, date_key, time_status, career_level, degree_seeking, continuation_type, demographic_key, headcount):
        """ method for instantiating object """
        self.unitid = unitid
        self.date_key = date_key
        self.time_status = time_status
        self.career_level = career_level
        self.degree_seeking = degree_seeking
        self.continuation_type = continuation_type
        self.demographic_key = demographic_key
        self.headcount = headcount

    def __repr__(self):
        """ produces human-readable object call """
        return (
            f'{self.__class__.__name__}('
            f'unitid={self.unitid!r}, '
            f'date_key={self.date_key!r}, '
            f'time_status={self.time_status!r}, '
            f'career_level={self.career_level!r}, '
            f'degree_seeking={self.degree_seeking!r}, '
            f'continuation_type={self.continuation_type!r}, '
            f'demographic_key={self.demographic_key!r}, '
            f'headcount={self.headcount!r})'
        )
