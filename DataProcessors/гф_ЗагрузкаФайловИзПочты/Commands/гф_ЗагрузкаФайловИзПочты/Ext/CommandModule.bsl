﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ОткрытьФорму(
		"Обработка.гф_ЗагрузкаФайловИзПочты.Форма.Форма",
		Новый Структура,
		ПараметрыВыполненияКоманды.Источник,
		"Обработка.гф_ЗагрузкаФайловИзПочты.Форма.Форма" + ?(ПараметрыВыполненияКоманды.Окно = Неопределено, ".ОтдельноеОкно", ""),
		ПараметрыВыполненияКоманды.Окно);

КонецПроцедуры
