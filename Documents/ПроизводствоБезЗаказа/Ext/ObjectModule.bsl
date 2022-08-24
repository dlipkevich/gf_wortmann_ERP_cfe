﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

&После("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	// #wortmann {
	// #5.2.04
	// необходимо, чтобы при проведении назначение подставлялось автоматически
	// Галфинд Sakovich 2022/08/03
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		ПустоеНазначение = ПредопределенноеЗначение("Справочник.Назначения.ПустаяСсылка");
		НазначениеПоУмолчанию = _омОбщегоНазначенияВызовСервера.ПолучитьГлобальноеЗначение(
		"СлужебноеНазначениеДляТоваров",
		ПустоеНазначение);
		Для каждого стрТч Из ВыходныеИзделия Цикл
			Если Не ЗначениеЗаполнено(стрТч.Назначение) Тогда	
				стрТч.Назначение = НазначениеПоУмолчанию;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	// } #wortmann
КонецПроцедуры

&Перед("ПередЗаписью")
Процедура гф_ПередЗаписью1(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	Продукция = ВыходныеИзделия.Выгрузить();
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	продукция.Номенклатура КАК Номенклатура,
	|	продукция.Характеристика КАК Характеристика,
	|	продукция.НомерСтроки КАК НомерСтроки
	|ПОМЕСТИТЬ тч
	|ИЗ
	|	&Продукция КАК продукция
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	тч.Номенклатура КАК Номенклатура,
	|	тч.Характеристика КАК Характеристика,
	|	СУММА(1) КАК Дублей
	|ПОМЕСТИТЬ Дубли
	|ИЗ
	|	тч КАК тч
	|
	|СГРУППИРОВАТЬ ПО
	|	тч.Номенклатура,
	|	тч.Характеристика
	|
	|ИМЕЮЩИЕ
	|	СУММА(1) > 1
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Дубли.Номенклатура КАК Номенклатура,
	|	Дубли.Характеристика КАК Характеристика,
	|	тч.НомерСтроки КАК НомерСтроки
	|ИЗ
	|	Дубли КАК Дубли
	|		ЛЕВОЕ СОЕДИНЕНИЕ тч КАК тч
	|		ПО Дубли.Номенклатура = тч.Номенклатура
	|			И Дубли.Характеристика = тч.Характеристика
	|ИТОГИ ПО
	|	Номенклатура,
	|	Характеристика");
	Запрос.УстановитьПараметр("Продукция", Продукция);
	Результат = Запрос.Выполнить();
	ВыборкаНоменклатура = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаНоменклатура.Следующий() Цикл
		ВыборкаХарактеристика = ВыборкаНоменклатура.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаХарактеристика.Следующий() Цикл
			ВыборкаДетали = ВыборкаХарактеристика.Выбрать();
			Пока ВыборкаДетали.Следующий() Цикл
				ТекстСообщения = "в строке " + ВыборкаДетали.НомерСтроки + " имеются дубли
				|по номенклатуре [" + ВыборкаДетали.Номенклатура +
				"] и характеристике [" + ВыборкаДетали.Характеристика + "]";
				ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, , , , Отказ);
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
