# coding=utf-8

from sqlalchemy import Column, ForeignKey, Index, String, Integer, Date, Boolean, Numeric

from base import Base

class IpedsInstitution(Base):
    """ map to a table name in db """
    __tablename__ = "ipeds_institutions"

    """ create columns """
    id = Column(Integer, primary_key = True)
    unitid = Column(Integer, nullable = False)
    date_key = Column(Date, ForeignKey('date_dimension.date_key'), nullable = False)
    institution_name = Column(String(255), nullable = False)
    address = Column(String(255), nullable = True)
    city = Column(String(255), nullable = True)
    zip_code = Column(String(10), nullable = True)
    web_address = Column(String(255), nullable = True)
    state_fips = Column(Integer, nullable = False, default = 0)
    county_fips = Column(Numeric(5, 3), nullable = False, default = 0)
    service_academy = Column(Boolean, nullable = False, default = 0)
    institution_level = Column(String(50), nullable = False, default='Unknown')
    control = Column(String(50), nullable = False, default='Unknown')
    highest_level_offering = Column(String(132), nullable = False, default='Unknown')
    highest_degree_offering = Column(String(132), nullable = False, default='Unknown')
    undergraduate_offering = Column(Boolean, nullable = False, default = 0)
    graduate_offering = Column(Boolean, nullable = False, default = 0)
    degree_granting = Column(Boolean, nullable = False, default = 0)
    locale = Column(String(64), nullable = False, default='Unknown')
    parent_id = Column(Integer, nullable = False)
    year_closed = Column(Integer, nullable = True)
    active = Column(Boolean, nullable = False, default = 0)
    cbsa_id = Column(Integer, nullable = False, default = -2)
    cbsa_type = Column(String(64), nullable = False, default = 'Not applicable')
    csa_id = Column(Integer, nullable = False, default = -2)
    longitude = Column(Numeric(18, 8), nullable = True)
    latitude = Column(Numeric(18, 8), nullable = True)
    system_member = Column(Boolean, nullable = False, default = 0)
    system_name = Column(String(255), nullable = False, default = 'No system')
    open_to_public = Column(Boolean, nullable = False, default = 0)
    landgrant = Column(Boolean, nullable = False, default = 0)
    hbcu = Column(Boolean, nullable = False, default = 0)
    hospital = Column(Boolean, nullable = False, default = 0)
    medical = Column(Boolean, nullable = False, default = 0)
    tribal = Column(Boolean, nullable = False, default = 0)
    rotc = Column(Boolean, nullable = False, default = 0)
    confno1 = Column(Integer, nullable = False, default = -2)
    confno2 = Column(Integer, nullable = False, default = -2)
    confno3 = Column(Integer, nullable = False, default = -2)
    confno4 = Column(Integer, nullable = False, default = -2)


    """ Unique index constraint """
    __table_args__ = (Index('idx_ipeds_institutions_keys',
                            'unitid',
                            'date_key',
                            unique = True), )

    def __init__(self, unitid, date_key, institution_name, address, city, zip, web_address, 
                 fips, county_fips, service_academy, institution_level, control, highest_level_offering,
                 highest_degree_offering, undergraduate_offering, graduate_offering, degree_granting,
                 locale, parent_id, year_closed, active, cbsa_id, cbsa_type, csa_id, longitude,
                 latitude, system_member, system_name, open_to_public, landgrant, hbcu, hospital,
                 medical, tribal, rotc, confno1, confno2, confno3, confno4):
        """ method for instantiating object """
        self.unitid = unitid 
        self.date_key = date_key 
        self.institution_name = institution_name 
        self.address = address 
        self.city = city 
        self.zip = zip 
        self.web_address = web_address 
        self.fips = fips 
        self.county_fips = county_fips 
        self.service_academy = service_academy 
        self.institution_level = institution_level 
        self.control = control 
        self.highest_level_offering = highest_level_offering 
        self.highest_degree_offering = highest_degree_offering 
        self.undergraduate_offering = undergraduate_offering 
        self.graduate_offering = graduate_offering 
        self.degree_granting = degree_granting 
        self.locale = locale 
        self.parent_id = parent_id 
        self.year_closed = year_closed 
        self.active = active
        self.cbsa_id = cbsa_id 
        self.cbsa_type = cbsa_type 
        self.csa_id = csa_id 
        self.longitude = longitude 
        self.latitude = latitude 
        self.system_member = system_member 
        self.system_name = system_name 
        self.open_to_public = open_to_public 
        self.landgrant = landgrant 
        self.hbcu = hbcu 
        self.hospital = hospital 
        self.medical = medical 
        self.tribal = tribal 
        self.rotc = rotc 
        self.confno1 = confno1 
        self.confno2 = confno2 
        self.confno3 = confno3 
        self.confno4 = confno4 


    def __repr__(self):
        """ produces human-readable object call """
        return (
            f'{self.__class__.__name__}('
            f'unitid={self.unitid!r}, '
            f'date_key={self.date_key!r}, '
            f'institution_name={self.institution_name!r}, '
            f'address={self.address!r}, '
            f'city={self.city!r}, '
            f'zip={self.zip!r}, '
            f'web_address={self.web_address!r}, '
            f'fips={self.fips!r}, '
            f'county_fips={self.county_fips!r}, '
            f'service_academy={self.service_academy!r}, '
            f'institution_level={self.institution_level!r}, '
            f'control={self.control!r}, '
            f'highest_level_offering={self.highest_level_offering!r}, '
            f'highest_degree_offering={self.highest_degree_offering!r}, '
            f'undergraduate_offering={self.undergraduate_offering!r}, '
            f'graduate_offering={self.graduate_offering!r}, '
            f'degree_granting={self.degree_granting!r}, '
            f'locale={self.locale!r}, '
            f'parent_id={self.parent_id!r}, '
            f'year_closed={self.year_closed!r}, '
            f'active={self.active!r}, '
            f'cbsa_id={self.cbsa_id!r}, '
            f'cbsa_type={self.cbsa_type!r}, '
            f'csa_id={self.csa_id!r}, '
            f'longitude={self.longitude!r}, '
            f'latitude={self.latitude!r}, '
            f'system_member={self.system_member!r}, '
            f'system_name={self.system_name!r}, '
            f'open_to_public={self.open_to_public!r}, '
            f'landgrant={self.landgrant!r}, '
            f'hbcu={self.hbcu!r}, '
            f'hospital={self.hospital!r}, '
            f'medical={self.medical!r}, '
            f'tribal={self.tribal!r}, '
            f'rotc={self.rotc!r}, '
            f'confno1={self.confno1!r}, '
            f'confno2={self.confno2!r}, '
            f'confno3={self.confno3!r}, '
            f'confno4={self.confno4!r})'
        )
