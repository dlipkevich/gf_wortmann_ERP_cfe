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
	
    // Изменена фиктивная запись в ТЧ (имитация WMS)
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee7ed187d3b8e2
	ТаблицаОтгруженных = ДокОбъект.ОтгружаемыеТовары;
	Для Каждого Строка Из ТаблицаОтгруженных Цикл
		Строка.Действие = Перечисления.ДействияСоСтрокамиОрдеровНаОтгрузку.НеОтгружать;	
	КонецЦикла;
	
	ТаблицаОтгруженных[0].Действие = Перечисления.ДействияСоСтрокамиОрдеровНаОтгрузку.Отгрузить;
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
