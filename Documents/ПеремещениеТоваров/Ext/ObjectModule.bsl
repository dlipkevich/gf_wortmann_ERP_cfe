﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

&Перед("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	// vvv Галфинд \ Sakovich 22.10.2022
	// иначе не изменить даже с помошью СДР
	Если Не ОбменДанными.Загрузка Тогда
	// ^^^ Галфинд \ Sakovich 22.10.2022 
		
		// #wortmann {
		// #5.2.08
		// ID запрет ручного изменения документа, при наличии свойства "ДокументОснование"
		// Галфинд Volkov 2022/08/23
		Если Не ЭтотОбъект.ДополнительныеСвойства.Свойство("ДокументОснование") 
			И ЗначениеЗаполнено(ЭтотОбъект.ДокументОснование) Тогда
			Отказ = Истина;
			СтрокаСообщения = НСтр("ru = 'Данный документ не доступен для ручного изменения. Введен на основании %1.'");
			ТекстСообщения = СтрШаблон(СтрокаСообщения, ЭтотОбъект.ДокументОснование);
			ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, ЭтотОбъект.ДокументОснование, , , Отказ);
		КонецЕсли;
		// } #wortmann
		
	// vvv Галфинд \ Sakovich 22.10.2022	
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 22.10.2022 
	
	// #wortmann {
	// При проведении необходимо перезаполнять тч "гф_ШтрихкодыУпаковок"
	// Галфинд Sakovich 2022/10/22
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		гф_ЗаполнитьШтрихкодыУпаковок();
	КонецЕсли;
	// } #wortmann
	
КонецПроцедуры

&После("ОбработкаПроверкиЗаполнения")
Процедура гф_ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	// #wortmann {
	// если склад-отправитель коробной, то тч. ТоварыВКоробах должна быть заполнена
	// Галфинд Sakovich 2022/10/26
	ЭтоКоробочныйСклад = УправлениеСвойствами.ЗначениеСвойства(СкладОтправитель, "гф_СкладыТоварыВКоробах") = Истина;
	Если ЭтоКоробочныйСклад Тогда
		Если гф_ТоварыВКоробах.Количество() = 0 Тогда
			СтрокаСообщения = НСтр("ru = 'Не заполнена табличная часть ""Товары в коробах""!.'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(СтрокаСообщения, ЭтотОбъект, "гф_ТоварыВКоробах", , Отказ);
		КонецЕсли;
	КонецЕсли;
	// } #wortmann
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
Процедура гф_ЗаполнитьШтрихкодыУпаковок()
	
	ДатаПроверкиОрдернойСхемы = ?(ЭтоНовый(), ТекущаяДатаСеанса(), Дата);
	
	СкладОтправительОрдерный = СкладыСервер.ИспользоватьОрдернуюСхемуПриОтгрузке(
		СкладОтправитель,
		ДатаПроверкиОрдернойСхемы);
	СкладПолучательОрдерный = СкладыСервер.ИспользоватьОрдернуюСхемуПриПоступлении(
		СкладПолучатель, 
		ДатаПроверкиОрдернойСхемы);
	
	Если СкладОтправительОрдерный И СкладПолучательОрдерный Тогда
		// 1. с_Ордерного_на_Ордерный
		// движения по рН "гф_ДвиженияКодовМаркировкиОрганиций" формируются приходными/расходными ордерами,
		// поэтому заполнение тч "гф_ШтрихкодыУпаковок" не производится
		Возврат;
	КонецЕсли;
	
	СкладОтправительВКоробах = УправлениеСвойствами.ЗначениеСвойства(СкладОтправитель, "гф_СкладыТоварыВКоробах");
	СкладПолучательВКоробах = УправлениеСвойствами.ЗначениеСвойства(СкладПолучатель, "гф_СкладыТоварыВКоробах");
	
	ЕстьОрдерныйСклад = СкладОтправительОрдерный Или СкладПолучательОрдерный;
	ЕстьКоробочныйСклад = СкладОтправительВКоробах Или СкладПолучательВКоробах;
	
	гф_ШтрихкодыУпаковок.Очистить();

	Если СкладОтправительОрдерный И Не СкладПолучательОрдерный Тогда 
		// 2. с_Ордерного_на_Виртуальный (УЛ или штрихкоды из расходного ордера)
		Если Статус = Перечисления.СтатусыПеремещенийТоваров.Принято Тогда
			Если СкладОтправительВКоробах И СкладПолучательВКоробах Тогда
				// 	2а коробной_коробной (будут движения: приход агрегаты, Агрегаты УЛ из расходного ордера)
				ЗаполнитьШтрихкоды("РасходныйОрдер", "Агрегаты");
			КонецЕсли;
			
			Если СкладОтправительВКоробах И Не СкладПолучательВКоробах Тогда
				// 	2б коробной_парный (будут движения: приход КМ, КМ из Агрегата УЛ из Расходного ордера)
				ЗаполнитьШтрихкоды("РасходныйОрдер", "КМ");
			КонецЕсли;
			
			Если Не (СкладОтправительВКоробах Или СкладПолучательВКоробах) Тогда
				ЗаполнитьШтрихкоды("РасходныйОрдер", "Штрихкоды");
				// 	2в парный_парный (будут движения: приход КМ, КМ из тч. Штрихкоды Расходного ордера)
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	Если Не СкладОтправительОрдерный И  СкладПолучательОрдерный Тогда 
		// 3. с_Виртуального_на_Ордерный (УЛ или штрихкоды из приходного ордера)
		Если Статус = Перечисления.СтатусыПеремещенийТоваров.Отгружено Тогда
			Если СкладОтправительВКоробах И СкладПолучательВКоробах Тогда
				// 	3а короробной_коробной (будут движения: расход агрегаты, Агрегаты из УЛ приходного ордера)
				ЗаполнитьШтрихкоды("ПриходныйОрдер", "Агрегаты");
			КонецЕсли;
			
			Если СкладОтправительВКоробах И Не СкладПолучательВКоробах Тогда
				// 	3б коробной_парный (будут движения: расход КМ, КМ из Агрегата из УЛ приходного ордера)
				ЗаполнитьШтрихкоды("ПриходныйОрдер", "КМ");
			КонецЕсли;
			
			Если Не (СкладОтправительВКоробах Или СкладПолучательВКоробах) Тогда
				// 	3в парный_парный (будут движения: расход КМ, КМ из тч. Штрихкоды Расходного ордера)
				ЗаполнитьШтрихкоды("ПриходныйОрдер", "Штрихкоды");
			КонецЕсли;
		КонецЕсли;	
	КонецЕсли;

КонецПроцедуры

// Заполняет табличную часть "гф_ШтрихкодыУпаковок"
//
// Параметры:
//  Источник - Строка - "РасходныйОрдер", "ПриходныйОрдер"
//  ВидВыборки - строка - "Агрегаты", "КМ", "Штрихкоды"
Процедура ЗаполнитьШтрихкоды(Источник, ВидВыборки)
	
	ТекстЗапроса = "";
	
	Если Источник  = "РасходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ
		|	ПриходныйОрдерНаТовары.Ссылка КАК Ордер
		|ПОМЕСТИТЬ Ордера
		|ИЗ
		|	Документ.ПриходныйОрдерНаТовары КАК ПриходныйОрдерНаТовары
		|ГДЕ
		|	ПриходныйОрдерНаТовары.Проведен
		|	И ПриходныйОрдерНаТовары.Распоряжение = &Распоряжение";
	КонецЕсли;
	Если Источник = "ПриходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	РасходныйОрдерНаТоварыТоварыПоРаспоряжениям.Ссылка КАК Ордер
		|ПОМЕСТИТЬ Ордера
		|ИЗ
		|	Документ.РасходныйОрдерНаТовары.ТоварыПоРаспоряжениям КАК РасходныйОрдерНаТоварыТоварыПоРаспоряжениям
		|ГДЕ
		|	РасходныйОрдерНаТоварыТоварыПоРаспоряжениям.Ссылка.Проведен
		|	И РасходныйОрдерНаТоварыТоварыПоРаспоряжениям.Распоряжение = &Распоряжение";
	КонецЕсли;
	
	ТекстЗапроса = ТекстЗапроса + ОбщегоНазначения.РазделительПакетаЗапросов();
	
	Если ВидВыборки = "Агрегаты" И Источник = "РасходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	РасходныйОрдерНаТоварыОтгружаемыеТовары.УпаковочныйЛист.гф_Агрегация КАК ШтрихкодУпаковки
		|ИЗ
		|	Ордера КАК Ордера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.РасходныйОрдерНаТовары.ОтгружаемыеТовары КАК РасходныйОрдерНаТоварыОтгружаемыеТовары
		|		ПО Ордера.Ордер = РасходныйОрдерНаТоварыОтгружаемыеТовары.Ссылка
		|ГДЕ
		|	РасходныйОрдерНаТоварыОтгружаемыеТовары.УпаковочныйЛист.гф_Агрегация ЕСТЬ НЕ NULL 
		|	И НЕ РасходныйОрдерНаТоварыОтгружаемыеТовары.УпаковочныйЛист.гф_Агрегация = ЗНАЧЕНИЕ(Справочник.ШтрихкодыУпаковокТоваров.ПустаяСсылка)";
	КонецЕсли;
	Если ВидВыборки = "Агрегаты" И Источник = "ПриходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПриходныйОрдерНаТоварыТовары.УпаковочныйЛист.гф_Агрегация КАК ШтрихкодУпаковки
		|ИЗ
		|	Ордера КАК Ордера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ПриходныйОрдерНаТовары.Товары КАК ПриходныйОрдерНаТоварыТовары
		|		ПО Ордера.Ордер = ПриходныйОрдерНаТоварыТовары.Ссылка
		|ГДЕ
		|	ПриходныйОрдерНаТоварыТовары.УпаковочныйЛист.гф_Агрегация ЕСТЬ НЕ NULL 
		|	И НЕ ПриходныйОрдерНаТоварыТовары.УпаковочныйЛист.гф_Агрегация = ЗНАЧЕНИЕ(Справочник.ШтрихкодыУпаковокТоваров.ПустаяСсылка)";
		
	КонецЕсли;
	Если ВидВыборки = "КМ" И Источник = "РасходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод КАК ШтрихкодУпаковки
		|ИЗ
		|	Ордера КАК Ордера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.РасходныйОрдерНаТовары.ОтгружаемыеТовары КАК РасходныйОрдерНаТоварыОтгружаемыеТовары
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ШтрихкодыУпаковокТоваровВложенныеШтрихкоды
		|			ПО РасходныйОрдерНаТоварыОтгружаемыеТовары.УпаковочныйЛист.гф_Агрегация = ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Ссылка
		|		ПО Ордера.Ордер = РасходныйОрдерНаТоварыОтгружаемыеТовары.Ссылка";
	КонецЕсли;
	Если ВидВыборки = "КМ" И Источник = "ПриходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод КАК ШтрихкодУпаковки
		|ИЗ
		|	Ордера КАК Ордера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ПриходныйОрдерНаТовары.Товары КАК ПриходныйОрдерНаТоварыТовары
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ШтрихкодыУпаковокТоваровВложенныеШтрихкоды
		|			ПО ПриходныйОрдерНаТоварыТовары.УпаковочныйЛист.гф_Агрегация = ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Ссылка
		|		ПО Ордера.Ордер = ПриходныйОрдерНаТоварыТовары.Ссылка";
	КонецЕсли;
	Если ВидВыборки = "Штрихкоды" И Источник = "РасходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	РасходныйОрдерНаТоварыШтрихкодыУпаковок.ШтрихкодУпаковки КАК ШтрихкодУпаковки
		|ИЗ
		|	Ордера КАК Ордера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.РасходныйОрдерНаТовары.ШтрихкодыУпаковок КАК РасходныйОрдерНаТоварыШтрихкодыУпаковок
		|		ПО Ордера.Ордер = РасходныйОрдерНаТоварыШтрихкодыУпаковок.Ссылка";
	КонецЕсли;
	Если ВидВыборки = "Штрихкоды" И Источник = "ПриходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПриходныйОрдерНаТоварыШтрихкодыУпаковок.ШтрихкодУпаковки КАК ШтрихкодУпаковки
		|ИЗ
		|	Ордера КАК Ордера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ПриходныйОрдерНаТовары.ШтрихкодыУпаковок КАК ПриходныйОрдерНаТоварыШтрихкодыУпаковок
		|		ПО Ордера.Ордер = ПриходныйОрдерНаТоварыШтрихкодыУпаковок.Ссылка";
	КонецЕсли;
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Распоряжение", Ссылка);
	Результат = Запрос.Выполнить();
	
	гф_ШтрихкодыУпаковок.Загрузить(Результат.Выгрузить());
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли