﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

// vvv Галфинд \ Sakovich 17.08.2023
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee2c84491f002d
&После("ПриЗаписи")
Процедура гф_ПриЗаписи(Отказ, Замещение)
	
	Если  Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаНабора Из ЭтотОбъект Цикл
		Если ЗначениеЗаполнено(СтрокаНабора["Характеристика"]) 
			И СтрокаНабора["гф_СостояниеВыгрузкиНоменклатуры"]  = Перечисления.гф_СтатусыGTIN_В_НК.GTINПолучен Тогда
			РостовкаКороба = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаНабора["Характеристика"], "гф_РостовкаКороба");
			Если РостовкаКороба = Истина Тогда
				гф_УстановитьШтрихкодВарианта(СтрокаНабора);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры // ^^^ Галфинд \ Sakovich 17.08.2023

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура гф_УстановитьШтрихкодВарианта(Запись)
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|	ВЫБРАТЬ
	|	Вариант.Ссылка КАК спрВариант,
	|	Вариант.гф_Штрихкод КАК ШтрихкодВарианта
	|ИЗ
	|	Справочник.ВариантыКомплектацииНоменклатуры КАК Вариант
	|ГДЕ
	|	Вариант.Владелец = &Номенклатура
	|	И Вариант.Характеристика = &Характеристика";
	Запрос.УстановитьПараметр("Номенклатура", Запись["Номенклатура"]);
	Запрос.УстановитьПараметр("Характеристика", Запись["Характеристика"]);
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если СокрЛП(Выборка["ШтрихкодВарианта"]) = "" Тогда
			обВариант = Выборка["спрВариант"].ПолучитьОбъект();
			Если обВариант <> Неопределено Тогда
				обВариант["гф_Штрихкод"] = Запись["Штрихкод"];
				обВариант.ОбменДанными.Загрузка = Истина;
				обВариант.Записать();
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти


#КонецЕсли
