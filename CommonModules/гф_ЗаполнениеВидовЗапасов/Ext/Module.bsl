﻿#Область ПрограммныйИнтерфейс

// #wortmann {
// #e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee593709e3289f
// Именить алгоритм заполнения ГТД в виде запасов по обувным товарам
// Галфинд Sakovich 2023/11/24
//
// Параметры:
// Источник - ДокументОбъект - записываемый объект  (см. ПодпискиНаСобытия.гф_ЗаполнитьВидыЗапасовПередЗаписью)
// Отказ - Булево - отказ от записи документа
// РежимЗаписи - ДокументОбъект.РежимЗаписиДокумента
// РежимПроведения - ДокументОбъект.РежимПроведенияДокумента
Процедура гф_ПерезаполнитьВидыЗапасовПередЗаписью(Источник, Отказ, РежимЗаписи, РежимПроведения) Экспорт
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;	
	
	Если Источник.ВидыЗапасов.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.КорректировкаНазначенияТоваров") Тогда
		// vvv Галфинд \ Sakovich 23.11.2023
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee8525b51e86c0
		
		тзВидыЗапасов = Источник.ВидыЗапасов.Выгрузить();
		тЗТовары = Источник.Товары.Выгрузить();
		
		Запрос = Новый Запрос;
		Запрос.Текст = ТекстЗапросаКорректировкаНазначенийГТДТоваров();
		Запрос.УстановитьПараметр("тзТовары", тзТовары);
		УстановитьПривилегированныйРежим(Истина);
		Результат = Запрос.Выполнить();
		УстановитьПривилегированныйРежим(Ложь);
		тзТовары = Результат.Выгрузить();
		
		Для каждого стрВидыЗапасов Из тзВидыЗапасов Цикл
			мСтрокТоваров = тзТовары.НайтиСтроки(Новый Структура(
			"АналитикаУчетаНоменклатуры, АналитикаУчетаНоменклатурыОприходование, НомерСтроки", 
			стрВидыЗапасов["АналитикаУчетаНоменклатуры"], стрВидыЗапасов["АналитикаУчетаНоменклатурыОприходование"], стрВидыЗапасов["НомерСтроки"]));
			Если мСтрокТоваров.ВГраница() = 0 Тогда
				СкладКоробочный = УправлениеСвойствами.ЗначениеСвойства(мСтрокТоваров[0]["Склад"], "гф_СкладыТоварыВКоробах") = Истина;
				ЭтоОбувнаяПродукция = мСтрокТоваров[0]["ОсобенностьУчета"] = Перечисления.ОсобенностиУчетаНоменклатуры.ОбувнаяПродукция;
				Если ЭтоОбувнаяПродукция И СкладКоробочный Тогда
					стрВидыЗапасов["НомерГТД"] = мСтрокТоваров[0]["НомерГТД"];
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		Источник.ВидыЗапасов.Загрузить(тзВидыЗапасов);
		Источник.ВидыЗапасовУказаныВручную = Истина;
		// ^^^ Галфинд \ Sakovich 23.11.2023
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.РеализацияТоваровУслуг") Тогда
		ИзменитьГТДВВидахЗапасов(Источник);
		////$$$===========================vvv ОТЛАДКА vvv======================25.11.2023 22:56:42=============| SBB
		//  Для каждого с Из Источник.ВидыЗапасов Цикл
		//		с["НомерГТД"] = "";
		//	КонецЦикла;
		////===========================^^^ КОНЕЦ ОТЛАДКИ ^^^===================25.11.2023 22:56:42=============| SBB
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.ПеремещениеТоваров") Тогда
		ИзменитьГТДВВидахЗапасов(Источник);
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.ПересортицаТоваров") Тогда
		ИзменитьГТДВВидахЗапасов(Источник);
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.СписаниеНедостачТоваров") Тогда
		ИзменитьГТДВВидахЗапасов(Источник);
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.ВнутреннееПотребление") Тогда
		ИзменитьГТДВВидахЗапасов(Источник);
	КонецЕсли;
	
КонецПроцедуры // #wortmann Галфинд Sakovich 2023/11/24

Процедура ИзменитьГТДВВидахЗапасов(Источник)
	
		тчШтрихкоды = Источник.ШтрихкодыУпаковок.Выгрузить();
		ТаблицаГТДПоНоменклатуре = ПолучитьТаблицуГТДПоНоменклатре(тчШтрихкоды);
		Если ТаблицаГТДПоНоменклатуре.Количество() =0 Тогда
			Возврат;	
		КонецЕсли;
		
		тчТовары = Источник.Товары.Выгрузить();
		ТаблицаАналитикаТоваровПоГТД = ПолучитьТаблицуАналитикиТоваровПоГТД(тчТовары, ТаблицаГТДПоНоменклатуре);
		Если ТаблицаАналитикаТоваровПоГТД.Количество() =0 Тогда
			Возврат;
		КонецЕсли;
		
		тзВидыЗапасов = Источник.ВидыЗапасов.Выгрузить();
		Для каждого стрВидыЗапасов Из тзВидыЗапасов Цикл
			стрПоиска = Новый Структура("АналитикаУчетаНоменклатуры", стрВидыЗапасов["АналитикаУчетаНоменклатуры"]);
			мСтрокТоваровПоГТД = ТаблицаАналитикаТоваровПоГТД.НайтиСтроки(стрПоиска);
			ВидыЗапасовИзменены = Ложь;
			Если мСтрокТоваровПоГТД.ВГраница() = -1 Тогда
				Продолжить;
			КонецЕсли;
			Если стрВидыЗапасов["НомерГТД"] <> мСтрокТоваровПоГТД[0]["НомерГТД"] Тогда
				стрВидыЗапасов["НомерГТД"] = мСтрокТоваровПоГТД[0]["НомерГТД"];
				ВидыЗапасовИзменены = Истина;
			КонецЕсли;
		КонецЦикла;
		Если ВидыЗапасовИзменены Тогда
			Источник.ВидыЗапасов.Загрузить(тзВидыЗапасов);
			Источник.ВидыЗапасовУказаныВручную = Истина;
		КонецЕсли;

КонецПроцедуры

Функция ТекстЗапросаКорректировкаНазначенийГТДТоваров()
	
	Возврат "
	|ВЫБРАТЬ
	|	тчТовары.НомерСтроки КАК НомерСтроки,
	|	тчТовары.Номенклатура КАК Номенклатура,
	|	тчТовары.КоличествоУпаковок КАК КоличествоУпаковок,
	|	тчТовары.Количество КАК Количество,
	|	тчТовары.Склад КАК Склад,
	|	тчТовары.АналитикаУчетаНоменклатуры КАК АналитикаУчетаНоменклатуры,
	|	тчТовары.АналитикаУчетаНоменклатурыОприходование КАК АналитикаУчетаНоменклатурыОприходование,
	|	тчТовары.гф_IDкороба КАК гф_IDкороба
	|ПОМЕСТИТЬ вт_Товары
	|ИЗ
	|	&тзТовары КАК тчТовары
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ШтрихкодыУпаковокТоваров.Ссылка КАК Ссылка,
	|	ШтрихкодыУпаковокТоваров.гф_НомерГТД КАК гф_НомерГТД,
	|	вт_Товары.гф_IDкороба КАК гф_IDкороба
	|ПОМЕСТИТЬ вт_ГТДАгрегатыШК
	|ИЗ
	|	Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ вт_Товары КАК вт_Товары
	|		ПО ШтрихкодыУпаковокТоваров.Ссылка = вт_Товары.гф_IDкороба.гф_Агрегация
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА НЕ вт_ГТДАгрегатыШК.гф_НомерГТД = ЗНАЧЕНИЕ(Справочник.НомераГТД.ПустаяСсылка)
	|			ТОГДА вт_ГТДАгрегатыШК.гф_НомерГТД
	|		ИНАЧЕ МАКСИМУМ(ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод.гф_НомерГТД)
	|	КОНЕЦ КАК НомерГТД,
	|	вт_ГТДАгрегатыШК.гф_IDкороба КАК гф_IDкороба
	|ПОМЕСТИТЬ вт_ГТД_ШК
	|ИЗ
	|	вт_ГТДАгрегатыШК КАК вт_ГТДАгрегатыШК
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ШтрихкодыУпаковокТоваровВложенныеШтрихкоды
	|		ПО вт_ГТДАгрегатыШК.Ссылка = ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	вт_ГТДАгрегатыШК.Ссылка,
	|	вт_ГТДАгрегатыШК.гф_НомерГТД,
	|	вт_ГТДАгрегатыШК.гф_IDкороба
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	вт_Товары.НомерСтроки КАК НомерСтроки,
	|	вт_Товары.Номенклатура КАК Номенклатура,
	|	вт_Товары.АналитикаУчетаНоменклатуры КАК АналитикаУчетаНоменклатуры,
	|	вт_Товары.АналитикаУчетаНоменклатурыОприходование КАК АналитикаУчетаНоменклатурыОприходование,
	|	вт_Товары.Склад КАК Склад,
	|	вт_Товары.Количество КАК Количество,
	|	вт_Товары.КоличествоУпаковок КАК КоличествоУпаковок,
	|	вт_Товары.гф_IDкороба КАК гф_IDкороба,
	|	вт_ГТД_ШК.НомерГТД КАК НомерГТД,
	|	спрНоменклатура.ОсобенностьУчета КАК ОсобенностьУчета
	|ИЗ
	|	вт_Товары КАК вт_Товары
	|		ЛЕВОЕ СОЕДИНЕНИЕ вт_ГТД_ШК КАК вт_ГТД_ШК
	|		ПО (вт_Товары.гф_IDкороба = вт_ГТД_ШК.гф_IDкороба)
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК спрНоменклатура
	|		ПО (вт_Товары.Номенклатура = спрНоменклатура.Ссылка)";
	
КонецФункции

Функция ПолучитьТаблицуГТДПоНоменклатре(тчШтрихкоды)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	тчШтрихкоды.ШтрихкодУпаковки КАК ШтрихкодУпаковки
	|ПОМЕСТИТЬ тчШтрихкоды
	|ИЗ
	|	&тчШтрихкоды КАК тчШтрихкоды
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	влШК.Штрихкод.Номенклатура КАК Номенклатура,
	|	влШК.Штрихкод.Характеристика КАК Характеристика,
	|	влШК.Штрихкод.гф_НомерГТД КАК НомерГТД
	|ПОМЕСТИТЬ втДанные
	|ИЗ
	|	тчШтрихкоды КАК тчШтрихкоды
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК Агрегаты
	|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК влШК
	|			ПО Агрегаты.Ссылка = влШК.Ссылка
	|		ПО тчШтрихкоды.ШтрихкодУпаковки = Агрегаты.Ссылка
	|ГДЕ
	|	Агрегаты.ТипУпаковки = ЗНАЧЕНИЕ(перечисление.ТипыУпаковок.МультитоварнаяУпаковка)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ШК.Номенклатура,
	|	ШК.Характеристика,
	|	ШК.гф_НомерГТД
	|ИЗ
	|	тчШтрихкоды КАК тчШтрихкоды
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШК
	|		ПО тчШтрихкоды.ШтрихкодУпаковки = ШК.Ссылка
	|ГДЕ
	|	ШК.ТипУпаковки = ЗНАЧЕНИЕ(перечисление.ТипыУпаковок.МаркированныйТовар)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втДанные.Номенклатура КАК Номенклатура,
	|	втДанные.Характеристика КАК Характеристика,
	|	МАКСИМУМ(втДанные.НомерГТД) КАК НомерГТД,
	|	ВЫБОР
	|		КОГДА втДанные.Номенклатура.ОсобенностьУчета = ЗНАЧЕНИЕ(Перечисление.ОсобенностиУчетаНоменклатуры.ОбувнаяПродукция)
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ЭтоОбувь
	|ИЗ
	|	втДанные КАК втДанные
	|
	|СГРУППИРОВАТЬ ПО
	|	втДанные.Номенклатура,
	|	втДанные.Характеристика,
	|	ВЫБОР
	|		КОГДА втДанные.Номенклатура.ОсобенностьУчета = ЗНАЧЕНИЕ(Перечисление.ОсобенностиУчетаНоменклатуры.ОбувнаяПродукция)
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ";
	
	Запрос.УстановитьПараметр("тчШтрихкоды", тчШтрихкоды);
	Результат = Запрос.Выполнить();
	ТаблицаГТДПоНоменклатуре = Результат.Выгрузить();
	
	Возврат ТаблицаГТДПоНоменклатуре;
	
КонецФункции // ()

Функция ПолучитьТаблицуАналитикиТоваровПоГТД(тчТовары, ТаблицаГТДПоНоменклатуре)
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	тчТовары.АналитикаУчетаНоменклатуры КАК АУН
	|ПОМЕСТИТЬ тчТовары
	|ИЗ
	|	&тчТовары КАК тчТовары
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	табГТД.Номенклатура КАК Номенклатура,
	|	табГТД.Характеристика КАК Характеристика,
	|	табГТД.НомерГТД КАК НомерГТД,
	|	табГТД.ЭтоОбувь КАК ЭтоОбувь
	|ПОМЕСТИТЬ табГТД
	|ИЗ
	|	&табГТД КАК табГТД
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	тчТовары.АУН КАК АналитикаУчетаНоменклатуры,
	|	МАКСИМУМ(табГТД.НомерГТД) КАК НомерГТД
	|ИЗ
	|	тчТовары КАК тчТовары
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.КлючиАналитикиУчетаНоменклатуры КАК КлючиАналитикиУчетаНоменклатуры
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ табГТД КАК табГТД
	|			ПО (КлючиАналитикиУчетаНоменклатуры.Номенклатура = табГТД.Номенклатура)
	|				И (КлючиАналитикиУчетаНоменклатуры.Характеристика = табГТД.Характеристика)
	|				И (табГТД.ЭтоОбувь)
	|		ПО (тчТовары.АУН = КлючиАналитикиУчетаНоменклатуры.Ссылка)
	|
	|СГРУППИРОВАТЬ ПО
	|	тчТовары.АУН";
	
	Запрос.УстановитьПараметр("тчТовары", тчТовары);
	Запрос.УстановитьПараметр("табГТД", ТаблицаГТДПоНоменклатуре);
	
	Результат = Запрос.Выполнить();
	ТаблицаАналитикаТоваровПоГТД = Результат.Выгрузить();
	
	Возврат ТаблицаАналитикаТоваровПоГТД;
	
КонецФункции


#КонецОбласти