﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область ОбработчикиСобытий

&Перед("ПередЗаписью")
Процедура гф_ПередЗаписью1(Отказ, РежимЗаписи, РежимПроведения)
	
	// #wortmann {
	// Галфинд Sakovich 2022/09/18
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
    // ++ Галфинд СадомцевСА 04.12.2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee855e1c0ca90e
	Если Не Отказ И  РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		Если ЗначениеЗаполнено(гф_Поставка) И ЗначениеЗаполнено(гф_Агрегация)
			И Не ЗначениеЗаполнено(гф_ДатаАгрегации)
			И ТипЗнч(гф_Поставка) = Тип("ДокументСсылка.ПроизводствоБезЗаказа") Тогда
			гф_ПодготовитьАгрегациюКМ(Отказ);
		КонецЕсли;
	КонецЕсли;
	// -- Галфинд СадомцевСА 04.12.2023
    // ++ Галфинд_ДомнышеваКР_27_10_2023
	// По русской Зиме ДатаАгрегации очищается, но при проведении когда Поставка заполнена должна заполниться
	Если Не Отказ И  РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		Если ЗначениеЗаполнено(гф_Поставка) И ЗначениеЗаполнено(гф_Агрегация)
			И Не ЗначениеЗаполнено(гф_ДатаАгрегации) Тогда
			гф_ДатаАгрегации = ТекущаяДатаСеанса();
		КонецЕсли;
	КонецЕсли;
	// --Галфинд_ДомнышеваКР_27_10_2023
	Если Не Отказ И  РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		Если Не ЗначениеЗаполнено(гф_ДатаАгрегации) Тогда
			гф_ПодготовитьАгрегациюКМ(Отказ);
		КонецЕсли;
	КонецЕсли;
	// } #wortmann
	
	// vvv Галфинд \ Sakovich 31.10.2023
	ДопПараметрРусскаяЗима = Неопределено;
	ДополнительныеСвойства.Свойство("РусскаяЗима", ДопПараметрРусскаяЗима);
	Если ДопПараметрРусскаяЗима = Истина И Не ЗначениеЗаполнено(гф_Поставка) Тогда
	РежимЗаписи = РежимЗаписиДокумента.Запись;
	гф_ДатаАгрегации = "";
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 31.10.2023
	
КонецПроцедуры

&Перед("ОбработкаПроверкиЗаполнения")
Процедура гф_ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	// #wortmann {
	// Галфинд Sakovich 2022/09/09
	Если Не ЗначениеЗаполнено(гф_Поставка) Тогда
		
		// vvv Галфинд \ Sakovich 31.10.2023
		//Текст = "Не заполнено поле ""Поставка/Отгрузка""";
		//ОбщегоНазначения.СообщитьПользователю(Текст, Ссылка, , "Объект.гф_Поставка", Отказ);
		ДопПараметрРусскаяЗима = Неопределено;
		Если ДополнительныеСвойства.Свойство("РусскаяЗима", ДопПараметрРусскаяЗима) 
			И Не ДопПараметрРусскаяЗима = Истина Тогда
			Текст = "Не заполнено поле ""Поставка/Отгрузка""";
			ОбщегоНазначения.СообщитьПользователю(Текст, Ссылка, , "Объект.гф_Поставка", Отказ);
		КонецЕсли;
		// ^^^ Галфинд \ Sakovich 31.10.2023
		
	КонецЕсли;
	Если Не ЗначениеЗаполнено(гф_Комплектация) Тогда
		Текст = "Не заполнено поле ""Комплектация (ростовка)""";
		ОбщегоНазначения.СообщитьПользователю(Текст, Ссылка, , "Объект.гф_Комплектация", Отказ);
	КонецЕсли;
	// } #wortmann

	// #wortmann {
	// Галфинд Sakovich 2022/12/19
	КодУпаковочногоЛистаЗаполненИУникален = ПроверитьУникальностьКодаУЛ();
	Если Не КодУпаковочногоЛистаЗаполненИУникален Тогда
		Текст = "Поле ""Код"" не заполнено, либо Код не является уникальным";
		ОбщегоНазначения.СообщитьПользователю(Текст, Ссылка, , "Объект.Код", Отказ);
	КонецЕсли;
	// } #wortmann
	
КонецПроцедуры 

&Перед("ОбработкаПроведения")
Процедура гф_ОбработкаПроведения(Отказ, РежимПроведения)
	
	Если Не Отказ И ЭтоУчетПоОбувнойПродукции() Тогда
		Если Не ЗначениеЗаполнено(гф_Агрегация) Тогда
		    ТекстСообщения = 
			"Не заполнено значение ""Агрегация КМ"".
			|Документ " + Ссылка + " по виду учета ""Обувная продукция "" не может быть проведен.";
			ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, , , , Отказ);
		КонецЕсли;
	КонецЕсли;
	
	// vvv Галфинд \ Sakovich 31.10.2023
	//не нужно тут отменять проведение, т.к. все изменения в базе, произведенные в транзакции записи - пропадают
	//(в частности пропадает созданная Агрегация). Сделаем это в "ПередЗаписью"...
	
	//// ++ Галфинд_ДомнышеваКР_27_10_2023
	//// По РусскойЗиме после создания Агрегации необходимо отменить проведение
	//Если Не ЗначениеЗаполнено(гф_Поставка) Тогда
	//	Текст = "Не заполнено поле ""Поставка/Отгрузка""";
	//	ОбщегоНазначения.СообщитьПользователю(Текст, Ссылка, , "Объект.гф_Поставка", Отказ);
	//КонецЕсли;
	//// -- Галфинд_ДомнышеваКР_27_10_2023
	
	// ^^^ Галфинд \ Sakovich 31.10.2023
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПроверитьУникальностьКодаУЛ()

	Если СокрЛП(Код) = "" Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	УпаковочныйЛист.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.УпаковочныйЛист КАК УпаковочныйЛист
	|ГДЕ
	|	УпаковочныйЛист.Код = &Код
	|	И НЕ УпаковочныйЛист.Ссылка = &Ссылка");
	Запрос.УстановитьПараметр("Код", Код);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Результат = Запрос.Выполнить();

	Возврат Результат.Пустой() = Истина;

КонецФункции // ()

Функция ЭтоУчетПоОбувнойПродукции()

	спрНоменклатура = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(гф_Комплектация, "Владелец");
	ОсобенностиУчета = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
	?(ЗначениеЗаполнено(спрНоменклатура), спрНоменклатура, Справочники.Номенклатура.ПустаяСсылка()),
	"ОсобенностьУчета");
	Если ОсобенностиУчета = Перечисления.ОсобенностиУчетаНоменклатуры.ОбувнаяПродукция Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;

КонецФункции 

Процедура гф_ПодготовитьАгрегациюКМ(Отказ)
	// ++Галфинд_ДомнышеваКР_16_06_2023 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee0a1be12f8135
	// Для создания УЛ из док.ЗаказПоставщику передаются доп.св-ва, так как Поставка еще не заполнена.        
	Если НЕ ДополнительныеСвойства.Свойство("РусскаяЗима") И
		// --Галфинд_ДомнышеваКР_16_06_2023	
		Не ЗначениеЗаполнено(гф_Поставка) Тогда
		ТекстСообщения = "Не заполнено значение ""Поставка/Отгрузка""";
		ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, , , , Отказ);	
		Возврат;	
	КонецЕсли;
	
	тчТовары = Товары.Выгрузить();
	
	Запрос = Новый Запрос("
	|ВЫБРАТЬ
	|	т.Номенклатура КАК Номенклатура,
	|	т.Характеристика КАК Характеристика,
	|	т.КоличествоУпаковок КАК КоличествоУпаковок,
	|	&Поставка КАК Поставка
	|ПОМЕСТИТЬ УпаковочныйЛистТовары
	|ИЗ
	|	&тчТовары КАК т
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ШтрихкодыУпаковокТоваров.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	|ГДЕ
	|	ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода = &КодУпаковочногоЛиста
	|	И ШтрихкодыУпаковокТоваров.ТипУпаковки = &ТипУпаковкиМультитоварная
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	УпаковочныйЛистТовары.Поставка КАК ПоставкаУЛ,
	|	УпаковочныйЛистТовары.Номенклатура КАК Номенклатура,
	|	УпаковочныйЛистТовары.Характеристика КАК Характеристика,
	|	УпаковочныйЛистТовары.КоличествоУпаковок КАК Количество,
	|	ШтрихкодыУпаковокТоваров.Ссылка КАК КМ,
	|	ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода КАК ЗначениеШтрихкода
	|ПОМЕСТИТЬ вт_свободныеШтрихкоды
	|ИЗ
	|	УпаковочныйЛистТовары КАК УпаковочныйЛистТовары
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК тчВложенныеШтрихкоды
	|			ПО ШтрихкодыУпаковокТоваров.Ссылка = тчВложенныеШтрихкоды.Штрихкод
	|		ПО (ШтрихкодыУпаковокТоваров.ТипУпаковки = &ТипУпаковкиМаркированныйТовар)
	|			И УпаковочныйЛистТовары.Номенклатура = ШтрихкодыУпаковокТоваров.Номенклатура
	|			И УпаковочныйЛистТовары.Характеристика = ШтрихкодыУпаковокТоваров.Характеристика
	|ГДЕ
	|	(тчВложенныеШтрихкоды.Ссылка ЕСТЬ NULL
	|			ИЛИ тчВложенныеШтрихкоды.Ссылка.ЗначениеШтрихкода = &КодУпаковочногоЛиста)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	вт_свободныеШтрихкоды.Номенклатура КАК Номенклатура,
	|	вт_свободныеШтрихкоды.Характеристика КАК Характеристика,
	|	вт_свободныеШтрихкоды.Количество КАК Количество,
	|	вт_свободныеШтрихкоды.КМ КАК КМ
	|ПОМЕСТИТЬ ПодобранныеШтрихкоды
	|ИЗ
	|	вт_свободныеШтрихкоды КАК вт_свободныеШтрихкоды
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ПулКодовМаркировкиСУЗ КАК ПулКодовМаркировкиСУЗ
	|		ПО вт_свободныеШтрихкоды.ЗначениеШтрихкода = ПулКодовМаркировкиСУЗ.КодМаркировки
	|			И вт_свободныеШтрихкоды.ПоставкаУЛ = ПулКодовМаркировкиСУЗ.ДокументОснование
	|			И (НЕ ПулКодовМаркировкиСУЗ.ДокументОснование ССЫЛКА Документ.ПересортицаТоваров)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПодобранныеШтрихкоды.Номенклатура КАК Номенклатура,
	|	ПодобранныеШтрихкоды.Характеристика КАК Характеристика,
	|	ПодобранныеШтрихкоды.Количество КАК Количество,
	|	ПодобранныеШтрихкоды.КМ КАК КМ
	|ИЗ
	|	ПодобранныеШтрихкоды КАК ПодобранныеШтрихкоды
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрНакопления.гф_ДвижениеКодовМаркировкиОрганизации.Остатки(
	|				&Граница,
	|				Организация = &Организация
	|					И Склад = &Склад
	|					И КМ В
	|						(ВЫБРАТЬ
	|							т.КМ
	|						ИЗ
	|							ПодобранныеШтрихкоды КАК т)) КАК гф_ДвижениеКодовМаркировкиОрганизацииОстатки
	|		ПО ПодобранныеШтрихкоды.КМ = гф_ДвижениеКодовМаркировкиОрганизацииОстатки.КМ
	|ГДЕ
	|	ЕСТЬNULL(гф_ДвижениеКодовМаркировкиОрганизацииОстатки.КоличествоОстаток, 0) > 0
	|ИТОГИ ПО
	|	Номенклатура,
	|	Характеристика,
	|	Количество");
	
	Если ЗначениеЗаполнено(гф_Организация) Тогда
		ПараметрОрганизация = гф_Организация;
	Иначе
		ПараметрОрганизация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(гф_Поставка, "гф_Поставка.Организация");
	КонецЕсли;
	// ++Галфинд_ДомнышеваКР_16_06_2023 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee0a1be12f8135
	// Для создания УЛ из док.ЗаказПоставщику передаются доп.св-ва, так как Поставка еще не заполнена.
	Если ДополнительныеСвойства.Свойство("ПараметрСклад") Тогда
		ПараметрСклад = ДополнительныеСвойства.ПараметрСклад; 
	Иначе 
		// --Галфинд_ДомнышеваКР_16_06_2023
		ПараметрСклад = гф_ОбработкаПроведения.гф_ПолучитьСкладИзДокументаОснования(гф_Поставка);
	КонецЕсли;
	ДатаАгрегации = ТекущаяДатаСеанса();
	
	Запрос.УстановитьПараметр("ТипУпаковкиМультитоварная", Перечисления.ТипыУпаковок.МультитоварнаяУпаковка);
	Запрос.УстановитьПараметр("ТипУпаковкиМаркированныйТовар", Перечисления.ТипыУпаковок.МаркированныйТовар);
	Запрос.УстановитьПараметр("КодУпаковочногоЛиста", Код);
	Запрос.УстановитьПараметр("тчТовары", тчТовары);
	Запрос.УстановитьПараметр("Граница",Новый Граница(ДатаАгрегации, ВидГраницы.Исключая));
	Запрос.УстановитьПараметр("Организация", ПараметрОрганизация);
	Запрос.УстановитьПараметр("Склад", ПараметрСклад);
	Запрос.УстановитьПараметр("Поставка", гф_Поставка);
	ПакетРезультатов = Запрос.ВыполнитьПакет();
	
	Если ПакетРезультатов[1].Пустой() Тогда
		ОбъектШтрихкод = Справочники.ШтрихкодыУпаковокТоваров.СоздатьЭлемент();	
		ОбъектШтрихкод.ТипУпаковки = Перечисления.ТипыУпаковок.МультитоварнаяУпаковка;
		ОбъектШтрихкод.ТипШтрихкода = Перечисления.ТипыШтрихкодов.GS1_128;
		ОбъектШтрихкод.ЗначениеШтрихкода = Код;
		ОбъектШтрихкод.гф_АртикулАгрегата = гф_Комплектация;
	Иначе
		Выборка = ПакетРезультатов[1].Выбрать();
		Выборка.Следующий();
		ОбъектШтрихкод = Выборка.Ссылка.ПолучитьОбъект();
		Если Не ЗначениеЗаполнено(ОбъектШтрихкод.гф_АртикулАгрегата) Тогда
			ОбъектШтрихкод.гф_АртикулАгрегата = гф_Комплектация;
		КонецЕсли;
	КонецЕсли;
	
	// vvv Галфинд \ Sakovich 14.07.2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee0441749bccbe
	СтатусАгрегации = Перечисления.гф_СтатусыКМ_в_ШК.АгрегацияИСМП;
	Если ОбъектШтрихкод.гф_Статус <> СтатусАгрегации Тогда
		ОбъектШтрихкод.гф_Статус = СтатусАгрегации;
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 14.07.2023 
	
	ВыборкаИтогиПоНоменклатуре = ПакетРезультатов[4].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	ЗаполнитьВложенныеШтрихкоды(ОбъектШтрихкод, ВыборкаИтогиПоНоменклатуре);
	
	ОбъектШтрихкод.ДополнительныеСвойства.Вставить("ОбработатьВложенныеШтрихкодыВПуле", Истина);
	
	Если ЭтоУчетПоОбувнойПродукции() Тогда
		КоличествоВложенныхШтрихкодов = ОбъектШтрихкод.ВложенныеШтрихкоды.Количество();
		ОбъектШтрихкод.Количество = КоличествоВложенныхШтрихкодов;
		Если КоличествоВложенныхШтрихкодов = Товары.Итог("КоличествоУпаковок") Тогда
			ОбъектШтрихкод.Записать();
			гф_Агрегация = ОбъектШтрихкод.Ссылка;
		Иначе
			ТекстСообщения = 
			"При создании агрегата Штрихкодов упаковок товаров не "
			+ "найдено достаточного количества кодов маркировки 
			|Документ ""Упаковочный лист"" по виду учета ""Обувная продукция "" не может быть проведен.";
			ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, , , , Отказ);
		КонецЕсли;
	Иначе
		ОбъектШтрихкод.Записать();
		гф_Агрегация = ОбъектШтрихкод.Ссылка;
	КонецЕсли;
	// vvv Галфинд \ Sakovich 20.07.2023
	Если Не ОбъектШтрихкод.Ссылка.Пустая() Тогда
		гф_ЭмиссияКодовМаркировкиВызовСервера.ЗаписатьИсторияСтатусовКМ(
		ДатаАгрегации,
		ОбъектШтрихкод.Ссылка,
		СтатусАгрегации,
		Ссылка);
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 20.07.2023 
	Если Не Отказ Тогда
		гф_ДатаАгрегации = ДатаАгрегации;
		ДополнительныеСвойства.Вставить("ПровестиСДатойАгрегации");
	КонецЕсли;
КонецПроцедуры

Процедура ЗаполнитьВложенныеШтрихкоды(ОбъектШтрихкод, ВыборкаНоменклатура)
	
	ОбъектШтрихкод.ВложенныеШтрихкоды.Очистить();
	Пока ВыборкаНоменклатура.Следующий() Цикл
		ВыборкаХарактеристика = ВыборкаНоменклатура.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаХарактеристика.Следующий() Цикл
			ВыборкаКоличество = ВыборкаХарактеристика.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаКоличество.Следующий() Цикл
				КоличествоКМ = ВыборкаКоличество.Количество;
				ВыборкаДетали = ВыборкаКоличество.Выбрать();
				Сч = 1;
				Пока Сч <= КоличествоКМ И ВыборкаДетали.Следующий() Цикл
					нс = ОбъектШтрихкод.ВложенныеШтрихкоды.Добавить();
					нс.Штрихкод = ВыборкаДетали.КМ;
					Сч = Сч + 1;
				КонецЦикла;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли