-- Calcula o progresso do dia/semana/mes/ano, a posicao do sol e a contagem
-- regressiva, e publica tudo como variaveis (DayPct, SunA, EventDays...).

function Initialize()
end

local function set(key, value)
	SKIN:Bang('!SetVariable', key, string.format('%.4f', value))
end

-- "05:31" -> fracao do dia
local function fraction(name)
	local m = SKIN:GetMeasure(name)
	if not m then return nil end
	local h, min = m:GetStringValue():match('(%d+):(%d+)')
	if not h then return nil end
	return (tonumber(h) * 60 + tonumber(min)) / 1440
end

function Update()
	local t = os.date('*t')
	local day = (t.hour * 3600 + t.min * 60 + t.sec) / 86400
	local weekday = (t.wday + 5) % 7 -- segunda = 0
	local days = os.date('*t', os.time{ year = t.year, month = t.month + 1, day = 0, hour = 12 }).day
	local leap = (t.year % 4 == 0 and t.year % 100 ~= 0) or t.year % 400 == 0

	set('DayPct', day * 100)
	set('WeekPct', (weekday + day) / 7 * 100)
	set('MonthPct', (t.day - 1 + day) / days * 100)
	set('YearPct', (t.yday - 1 + day) / (leap and 366 or 365) * 100)

	set('SunA', fraction('MeasureSunrise') or 0.25)
	set('SunB', fraction('MeasureSunset') or 0.75)
	set('NowF', day)

	local y, mo, d = (SKIN:GetVariable('EventDate') or ''):match('(%d+)%-(%d+)%-(%d+)')
	if y then
		local target = os.time{ year = tonumber(y), month = tonumber(mo), day = tonumber(d), hour = 12 }
		local today = os.time{ year = t.year, month = t.month, day = t.day, hour = 12 }
		SKIN:Bang('!SetVariable', 'EventDays', tostring(math.floor((target - today) / 86400 + 0.5)))
	end
	return day * 100
end
