﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКомандыКонецПроцедуры
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиент.ПослеЗаписи(ЭтотОбъект, Объект, ПараметрыЗаписи);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

// СтандартныеПодсистемы.ПодключаемыеКоманды

&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПродолжитьВыполнениеКомандыНаСервере(ПараметрыВыполнения, ДополнительныеПараметры) Экспорт
	ВыполнитьКомандуНаСервере(ПараметрыВыполнения);
КонецПроцедуры

&НаСервере
Процедура ВыполнитьКомандуНаСервере(ПараметрыВыполнения)
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры

// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

&НаКлиенте
Процедура ЗагрузитьКМизФайла(Команда)
	ПараметрыЗагрузки = ЗагрузкаДанныхИзФайлаКлиент.ПараметрыЗагрузкиДанных();
	ПараметрыЗагрузки.ПолноеИмяТабличнойЧасти = "гф_ВводНачальныхОстатковКМ.ШтрихкодыУпаковокТоваров";
	ПараметрыЗагрузки.Заголовок = НСтр("ru = 'Загрузка кодов маркировки из файла'");
	ДополнительныеПараметры = Новый Структура();
	ПараметрыЗагрузки.ДополнительныеПараметры = ДополнительныеПараметры;
	Оповещение = Новый ОписаниеОповещения("ЗагрузитьКмИзФайлаЗавершение", ЭтотОбъект);
	ЗагрузкаДанныхИзФайлаКлиент.ПоказатьФормуЗагрузки(ПараметрыЗагрузки, Оповещение);
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьКмИзФайлаЗавершение(АдресЗагруженныхДанных, ДополнительныеПараметры) Экспорт
	Если АдресЗагруженныхДанных = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	ЗагрузитьКмИзФайлаНаСервере(АдресЗагруженныхДанных);
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьКмИзФайлаНаСервере(АдресЗагруженныхДанных)
	ЗагруженныеДанные = ПолучитьИзВременногоХранилища(АдресЗагруженныхДанных);
	КмДобавлены = Ложь;
	Для каждого СтрокаТаблицы Из ЗагруженныеДанные Цикл 
		Если Не ЗначениеЗаполнено(СтрокаТаблицы.ЗначениеШтрихкода) Тогда 
			Продолжить;
		КонецЕсли;
		НоваяСтрокаКм = Объект.ШтрихкодыУпаковокТоваров.Добавить();
		НоваяСтрокаКм.ЗначениеШтрихкода = СокрЛП(СтрокаТаблицы.ЗначениеШтрихкода);
		НоваяСтрокаКм.GTIN = СокрЛП(СтрокаТаблицы.GTIN);
		НоваяСтрокаКм.НомерГТД = СокрЛП(СтрокаТаблицы.НомерГТД);
		НоваяСтрокаКм.СтранаПроисхождения = СтрокаТаблицы.СтранаПроисхождения;
		НоваяСтрокаКм.спрНомерГТД = СтрокаТаблицы.спрНомерГТД;
		КмДобавлены = Истина;
	КонецЦикла;
	Если КмДобавлены Тогда
		Модифицированность = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПодобратьGTIN(Команда)
	ПодобратьGTINНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПодобратьGTINНаСервере()
	
	тч = Объект.ШтрихкодыУпаковокТоваров.Выгрузить();
	//тч =  Новый ТаблицаЗначений;
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	т.ЗначениеШтрихкода КАК ЗначениеШтрихкода,
	|	ПОДСТРОКА(т.ЗначениеШтрихкода, 5, 14) КАК GTIN_5_14,
	|	ПОДСТРОКА(т.ЗначениеШтрихкода, 5, 13) КАК GTIN_5_13,
	|	ПОДСТРОКА(т.ЗначениеШтрихкода, 4, 13) КАК GTIN_4_13,
	|	ПОДСТРОКА(т.ЗначениеШтрихкода, 3, 14) КАК GTIN_3_14,
	|	ПОДСТРОКА(т.ЗначениеШтрихкода, 6, 13) КАК GTIN_6_13
	|ПОМЕСТИТЬ втШтрихкоды
	|ИЗ
	|	&тч КАК т
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втШтрихкоды.ЗначениеШтрихкода КАК ЗначениеШтрихкода,
	|	ВЫБОР
	|		КОГДА ШтрихкодыНоменклатуры_5_14.Штрихкод ЕСТЬ НЕ NULL 
	|			ТОГДА ШтрихкодыНоменклатуры_5_14.Штрихкод
	|		КОГДА ШтрихкодыНоменклатуры_5_13.Штрихкод ЕСТЬ НЕ NULL 
	|			ТОГДА ШтрихкодыНоменклатуры_5_13.Штрихкод
	|		КОГДА ШтрихкодыНоменклатуры_4_13.Штрихкод ЕСТЬ НЕ NULL 
	|			ТОГДА ШтрихкодыНоменклатуры_4_13.Штрихкод
	|		КОГДА ШтрихкодыНоменклатуры_3_14.Штрихкод ЕСТЬ НЕ NULL 
	|			ТОГДА ШтрихкодыНоменклатуры_3_14.Штрихкод
	|		КОГДА ШтрихкодыНоменклатуры_6_13.Штрихкод ЕСТЬ НЕ NULL 
	|			ТОГДА ШтрихкодыНоменклатуры_6_13.Штрихкод
	|		ИНАЧЕ """"
	|	КОНЕЦ КАК GTIN
	|ИЗ
	|	втШтрихкоды КАК втШтрихкоды
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры_5_14
	|		ПО втШтрихкоды.GTIN_5_14 = ШтрихкодыНоменклатуры_5_14.Штрихкод
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры_5_13
	|		ПО втШтрихкоды.GTIN_5_13 = ШтрихкодыНоменклатуры_5_13.Штрихкод
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры_4_13
	|		ПО втШтрихкоды.GTIN_4_13 = ШтрихкодыНоменклатуры_4_13.Штрихкод
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры_3_14
	|		ПО втШтрихкоды.GTIN_3_14 = ШтрихкодыНоменклатуры_3_14.Штрихкод
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры_6_13
	|		ПО втШтрихкоды.GTIN_6_13 = ШтрихкодыНоменклатуры_6_13.Штрихкод";
	Запрос.УстановитьПараметр("тч", тч);
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Для каждого стрТч Из тч Цикл
		Выборка.Сбросить();
		СтрПоиска = Новый Структура("ЗначениеШтрихкода", стрТч["ЗначениеШтрихкода"]);
		Если Выборка.НайтиСледующий(СтрПоиска) Тогда
			стрТч["GTIN"] = Выборка["GTIN"];
		КонецЕсли;
	КонецЦикла;
	Объект.ШтрихкодыУпаковокТоваров.Загрузить(тч);
	
КонецПроцедуры

#КонецОбласти