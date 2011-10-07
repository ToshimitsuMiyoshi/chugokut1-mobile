# holiday.rb: Written by Tadayoshi Funaba 1998-2006
# $Id: holiday.rb,v 2.16 2006-12-30 21:44:10+09 tadf Exp $

require 'date'

class Date

  def fixed?
    return false unless jd >= 2432753	# 1948-07-20/PooD
    *x = mon, mday
    (x == [ 1,  1]) ||			# --01-01
    (x == [ 1, 15]  &&			# --01-15 (1948-07-20/1999-12-31)
     jd <= 2451544) ||
    (x == [ 2, 11]  &&			# --02-11 (1966-12-09/PooD)
     jd >= 2439469) ||
    (x == [ 4, 29]) ||			# --04-29
    (x == [ 5,  3]) ||			# --05-03
    (x == [ 5,  4]  &&			# --05-04 (2007-01-01/PooD)
     jd >= 2454102) ||
    (x == [ 5,  5]) ||			# --05-05
    (x == [ 7, 20]  &&			# --07-20 (1996-01-01/2002-12-31)
     jd >= 2450084  &&
     jd <= 2452640) ||
    (x == [ 9, 15]  &&			# --09-15 (1966-06-25/2002-12-31)
     jd >= 2439302  &&
     jd <= 2452640) ||
    (x == [10, 10]  &&			# --10-10 (1966-06-25/1999-12-31)
     jd >= 2439302  &&
     jd <= 2451544) ||
    (x == [11,  3]) ||			# --11-03
    (x == [11, 23]) ||			# --11-23
    (x == [12, 23]  &&			# --12-23 (1989-02-17/PooD)
     jd >= 2447575)
  end

  def float?
    (mon ==  1 && nth_kday?(2, 1) &&	# 2nd Mon, Jan (2000-01-01/PooD)
     jd >= 2451545) ||
    (mon ==  7 && nth_kday?(3, 1) &&	# 3nd Mon, Jul (2003-01-01/PooD)
     jd >= 2452641) ||
    (mon ==  9 && nth_kday?(3, 1) &&	# 3nd Mon, Sep (2003-01-01/PooD)
     jd >= 2452641) ||
    (mon == 10 && nth_kday?(2, 1) &&	# 2nd Mon, Oct (2000-01-01/PooD)
     jd >= 2451545)
  end

  private :fixed?, :float?

  def _deq(a, b, y)
    (a + 0.242194 * (y - 1980) - ((y - b) / 4).to_i).to_i
  end

  def _veq(y)
    case y
    when 1851..1899; a = 19.8277; b = 1983.0
    when 1900..1979; a = 20.8357; b = 1983.0
    when 1980..2099; a = 20.8431; b = 1980.0
    when 2100..2150; a = 21.8510; b = 1980.0
    else; raise ArgumentError, 'domain error'
    end
    civil_to_jd(y, 3, _deq(a, b, y))
  end

  def _aeq(y)
    case y
    when 1851..1899; a = 22.2588; b = 1983.0
    when 1900..1979; a = 23.2588; b = 1983.0
    when 1980..2099; a = 23.2488; b = 1980.0
    when 2100..2150; a = 24.2488; b = 1980.0
    else; raise ArgumentError, 'domain error'
    end
    civil_to_jd(y, 9, _deq(a, b, y))
  end

  private :_deq, :_veq, :_aeq

  def veq?
    return false unless (2432753..2506696) === jd	# 1948-07-20/2150-12-31
    jd == _veq(year)
  end

  def aeq?
    return false unless (2432753..2506696) === jd	# 1948-07-20/2150-12-31
    jd == _aeq(year)
  end

  private :veq?, :aeq?

  def nhol2? () fixed? || float? || veq? || aeq? end

  def need_subs?
    nhol2? && (sunday? || (self - 1).need_subs?)
  end

  protected :nhol2?, :need_subs?

  def nhol32?
    if jd >= 2441785
      if jd <= 2454101					# 1973-04-12/2006-12-31
	self.monday? && (self - 1).nhol2?
      else						# 2007-01-01/PooD
	!nhol2? && (self - 1).need_subs?
      end
    end
  end

  def nhol33?
    if jd >= 2446427
      if jd <= 2454101					# 1985-12-27/2006-12-31
	!sunday? && !nhol32? &&
	  (self - 1).nhol2? && (self + 1).nhol2?
      else						# 2007-01-01/PooD
	!nhol2? &&
	  (self - 1).nhol2? && (self + 1).nhol2?
      end
    end
  end

  def nholx?
    jd == 2436669 ||	# 1959-04-10 # 16
    jd == 2447582 ||	# 1989-02-24
    jd == 2448208 ||	# 1990-11-12
    jd == 2449148	# 1993-06-09
  end

  private :nhol32?, :nhol33?, :nholx?

  def national_holiday?
    d = if julian? then self.gregorian else self end
    d.instance_eval do nhol2? || nhol32? || nhol33? || nholx? end
  end

  def qfixed?
    return false unless (2405163..2432752) === jd	# 1873-01-04/1948-07-19
    *x = mon, mday
    (x == [ 1,  3] && (2405446..2432752) === jd) ||	# 1873-10-14/1948-07-19
    (x == [ 1,  5] && (2405446..2432752) === jd) ||	# 1873-10-14/1948-07-19
    (x == [ 1, 29] && (2405143..2405224) === jd) ||	# 1872-12-15/1873-03-06
    (x == [ 1, 30] && (2405446..2419649) === jd) ||	# 1873-10-14/1912-09-03
    (x == [ 2, 11] && (2405225..2432752) === jd) ||	# 1873-03-07/1948-07-19
    (x == [ 4,  3] && (2405446..2432752) === jd) ||	# 1873-10-14/1948-07-19
    (x == [ 4, 29] && (2424943..2432752) === jd) ||	# 1927-03-03/1948-07-19
    (x == [ 7, 30] && (2419650..2424942) === jd) ||	# 1912-09-04/1927-03-02
    (x == [ 8, 31] && (2419650..2424942) === jd) ||	# 1912-09-04/1927-03-02
    (x == [ 9, 17] && (2405446..2407535) === jd) ||	# 1873-10-14/1879-07-04
    (x == [10, 17] && (2407536..2432752) === jd) ||	# 1879-07-05/1948-07-19
    (x == [10, 31] && (2419967..2424942) === jd) ||	# 1913-07-18/1927-03-02
    (x == [11,  3] && (2405163..2419649) === jd) ||	# 1873-01-04/1912-09-03
    (x == [11,  3] && (2424943..2432752) === jd) ||	# 1927-03-03/1948-07-19
    (x == [11, 23] && (2405446..2432752) === jd) ||	# 1873-10-14/1948-07-19
    (x == [12, 25] && (2424943..2432752) === jd)	# 1927-03-03/1948-07-19
  end

  private :qfixed?

  def qveq?
    return false unless (2405163..2432752) === jd	# 1873-01-04/1948-07-19
    jd == _veq(year)
  end

  def qaeq?
    return false unless (2405163..2432752) === jd	# 1873-01-04/1948-07-19
    jd == _aeq(year)
  end

  private :qveq?, :qaeq?

  def qnholx?
    jd == 2420812 ||	# 1915-11-10 # 160
    jd == 2420816 ||	# 1915-11-14 # 160
    jd == 2420818 ||	# 1915-11-16 # 160
    jd == 2425561 ||	# 1928-11-10 # 226
    jd == 2425565 ||	# 1928-11-14 # 226
    jd == 2425567	# 1928-11-16 # 226
  end

  private :qnholx?

  def old_national_holiday?
    d = if julian? then self.gregorian else self end
    d.instance_eval do
      qfixed? || qnholx? ||
	((2407141..2432752) === jd && (qveq? || qaeq?))# 1878-06-05/1948-07-19
    end
  end

  def self.julian_easter(y, sg=ITALY)
    a = y % 4
    b = y % 7
    c = y % 19
    d = (19 * c + 15) % 30
    e = (2 * a + 4 * b - d + 34) % 7
    f, g = (d + e + 114).divmod(31)
    jd = civil_to_jd(y, f, g + 1, JULIAN)
    new!(jd_to_ajd(jd, 0, 0), 0, sg)
  end

  def self.gregorian_easter(y, sg=ITALY)
    a = y % 19
    b, c = y.divmod(100)
    d, e = b.divmod(4)
    f = ((b + 8) / 25).to_i
    g = ((b - f + 1) / 3).to_i
    h = (19 * a + b - d - g + 15) % 30
    i, k = c.divmod(4)
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = ((a + 11 * h + 22 * l) / 451).to_i
    n, p = (h + l - 7 * m + 114).divmod(31)
    jd = civil_to_jd(y, n, p + 1, GREGORIAN)
    new!(jd_to_ajd(jd, 0, 0), 0, sg)
  end

  class << self; alias_method :easter, :gregorian_easter end

  def easter?
    self ===
      (if julian?
	 self.class.julian_easter(year)
       else
	 self.class.gregorian_easter(year)
       end)
  end

end
