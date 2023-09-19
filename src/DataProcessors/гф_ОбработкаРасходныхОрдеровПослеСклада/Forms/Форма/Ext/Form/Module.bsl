﻿
&НаСервере
Процедура РазбитьНаСервере()
	
	ОбъектОбработка = РеквизитФормыВЗначение("Объект");
	ОбъектОбработка.ВыполнитьОперацииСРасходнымиОрдерами();
	
КонецПроцедуры

&НаКлиенте
Процедура Разбить(Команда)
	РазбитьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОтгрузитьНаСервере()
	
	ДокОбъект = РасходныйОрдер.ПолучитьОбъект();
	ТаблицаОтгруженных = ДокОбъект.ОтгружаемыеТовары;
	
    ТаблицаОтгруженных[0].Действие = Перечисления.ДействияСоСтрокамиОрдеровНаОтгрузку.Отгрузить;
	ТаблицаОтгруженных[1].Действие = Перечисления.ДействияСоСтрокамиОрдеровНаОтгрузку.НеОтгружать;
	ДокОбъект.Статус = Перечисления.СтатусыРасходныхОрдеров.КОтгрузке;

	ПараметрыУказанияСерий = Новый ФиксированнаяСтруктура(НоменклатураСервер.ПараметрыУказанияСерий(ДокОбъект, Документы.РасходныйОрдерНаТовары));
    НоменклатураСервер.ЗаполнитьСтатусыУказанияСерий(ДокОбъект, ПараметрыУказанияСерий.ОтгружаемыеТовары); 
	
	ДокОбъект.ДополнительныеСвойства.Вставить("гф_ОбменСоСкладом", Истина);
	Попытка
		ДокОбъект.Записать(РежимЗаписиДокумента.Проведение);
	Исключение
	    ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не вариант " + ИнформацияОбОшибке());
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьОтгрузить(Команда)
	ЗаполнитьОтгрузитьНаСервере();
КонецПроцедуры
