﻿
// vvv Галфинд \ Sakovich 28.12.2022
Процедура ОбработатьИсключенияРМКладовщика() Экспорт
	
	////$$$===========================vvv ОТЛАДКА vvv======================28.12.2022 12:43:57=============| SBB
	//_омОбщегоНазначенияВызовСервера.гф_ПаузаНаСервере(10);
	//ОбщегоНазначения.СообщитьПользователю("Выполнена серверная часть " + ТекущаяДатаСеанса());
	////===========================^^^ КОНЕЦ ОТЛАДКИ ^^^===================28.12.2022 12:43:57=============| SBB
	
	УстановитьПривилегированныйРежим(Истина);
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Таблица.Ссылка КАК Ссылка,
	|	Таблица.Ссылка.ДокументОснование КАК Основание
	|ИЗ
	|	Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК Таблица
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СтатусыДокументовИСМП КАК Статусы
	|		ПО (Статусы.Документ = Таблица.Ссылка)
	|ГДЕ
	|	Таблица.Проведен
	|	И Таблица.ДокументОснование ССЫЛКА Документ.ПересортицаТоваров
	|	И ВЫРАЗИТЬ(Таблица.ДокументОснование КАК Документ.ПересортицаТоваров).Проведен
	|	И Статусы.ДальнейшееДействие1 = ЗНАЧЕНИЕ(Перечисление.ДальнейшиеДействияПоВзаимодействиюИСМП.НеТребуется)
	|	И Статусы.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыОбработкиЗаказовНаЭмиссиюКодовМаркировкиИСМП.СУЗКодыМаркировкиЭмитированы)";	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		Основание = Выборка["Основание"];
		Агрегат = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Основание, "гф_IDКороба.гф_Агрегация");
		пNVE = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Агрегат, "ЗначениеШтрихкода");
		СозданаЗаписьСтатусовИсключений = ЗанестиВРС_ОбработкаИсключений(пNVE, ПредопределенноеЗначение("Перечисление.гф_СтатусыИсключений.КодыПолучены"));
		Если СозданаЗаписьСтатусовИсключений  = Истина Тогда
			ИзменитьДанныеУпаковочныйЛистИШтрихкодУпаковки(пNVE, Выборка.Ссылка, Основание);
			Если Основание.Проведен Тогда
				Основание.Записать(РежимЗаписиДокумента.Проведение);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры // ^^^ Галфинд \ Sakovich 28.12.2022 

Функция ЗанестиВРС_ОбработкаИсключений(пNVE, СтатусОбработкиИсключения)
	
	Если ПустаяСтрока(пNVE) Тогда
		Возврат Ложь;
	КонецЕсли;	
	
	ТекДата = ТекущаяДатаСеанса();
	Агрегат = Справочники.ШтрихкодыУпаковокТоваров.НайтиПоРеквизиту("ЗначениеШтрихкода", пNVE);
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	гф_ОбработкаИсключенийСрезПоследних.NVE КАК NVE
	|ИЗ
	|	РегистрСведений.гф_ОбработкаИсключений.СрезПоследних(, NVE = &Агрегат) КАК гф_ОбработкаИсключенийСрезПоследних
	|ГДЕ
	|	гф_ОбработкаИсключенийСрезПоследних.Период < &Период
	|	И гф_ОбработкаИсключенийСрезПоследних.Статус = &Статус");
	Запрос.УстановитьПараметр("Агрегат", Агрегат);
	Запрос.УстановитьПараметр("Период", ТекущаяДатаСеанса());
	Запрос.УстановитьПараметр("Статус", Перечисления.гф_СтатусыИсключений.ИсключениеСоздано);
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Ложь;
	КонецЕсли;
	Выборка = Результат.Выбрать();
	Выборка.Следующий();
	
	НЗ = РегистрыСведений.гф_ОбработкаИсключений.СоздатьНаборЗаписей();
	НЗ.Отбор.NVE.Установить(Агрегат);
	НЗ.Отбор.Период.Установить(ТекДата);
	НЗ.Прочитать();
	НЗ.Очистить();
	НовЗапись = НЗ.Добавить();
	НовЗапись.Период = ТекДата;
	НовЗапись.NVE = Агрегат;
	НовЗапись.Статус = СтатусОбработкиИсключения;
	
	Попытка
		НЗ.Записать();
		Возврат Истина;
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		ЗаписьЖурналаРегистрации("Ошибка установки статуса Обработки исключений", УровеньЖурналаРегистрации.Предупреждение, Метаданные.РегистрыСведений.гф_ОбработкаИсключений,,ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции

// Параметры: 
// 	пNVE - Строка - значение штрихкода агрегации Упаковочного листа
Процедура ИзменитьДанныеУпаковочныйЛистИШтрихкодУпаковки(пNVE, Эмиссия, Пересортица)
	
	Если ПустаяСтрока(пNVE) Тогда
		Возврат;
	КонецЕсли;	

	СтруктураШтрихкодУпаковочныйЛист = НайтиШтрикходУпаковкиТоваровИУпаковочныйЛистПоNVE(пNVE);
	Если СтруктураШтрихкодУпаковочныйЛист = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	УЛ = СтруктураШтрихкодУпаковочныйЛист["УпаковочныйЛист"];
	Агрегат = СтруктураШтрихкодУпаковочныйЛист["ШтрихКодУпаковки"];
	
	Запрос = Новый Запрос("
	|ВЫБРАТЬ
	|	УдаляемыеШК.Пересортица КАК Пересортица,
	|	УдаляемыеШК.ШтрихкодУпаковки КАК спрШтрихкод,
	|	ШтрихкодыУпаковокТоваров.Номенклатура КАК Номенклатура,
	|	ШтрихкодыУпаковокТоваров.Характеристика КАК Характеристика
	|ПОМЕСТИТЬ втУдаляемые
	|ИЗ
	|	РегистрСведений.гф_ПересортицаУдаляемыеШК КАК УдаляемыеШК
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	|		ПО УдаляемыеШК.ШтрихкодУпаковки = ШтрихкодыУпаковокТоваров.Ссылка
	|ГДЕ 
	|	УдаляемыеШК.Пересортица = &Пересортица
	|	И УдаляемыеШК.Пересортица.Проведен
	|	И НЕ УдаляемыеШК.Обработан
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗаказНаЭмиссиюКодовМаркировкиСУЗ.Ссылка КАК ЗаказНаЭмиссию,
	|	ПересортицаТоваров.Ссылка КАК Пересортировка
	|ПОМЕСТИТЬ ДокументыЭмиссии
	|ИЗ
	|	Документ.ПересортицаТоваров КАК ПересортицаТоваров
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК ЗаказНаЭмиссиюКодовМаркировкиСУЗ
	|		ПО ПересортицаТоваров.Ссылка = ЗаказНаЭмиссиюКодовМаркировкиСУЗ.ДокументОснование
	|ГДЕ
	|	ПересортицаТоваров.Ссылка = &Пересортица
	|	И ЗаказНаЭмиссиюКодовМаркировкиСУЗ.Ссылка = &Эмиссия
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ШтрихкодыУпаковокТоваров.Ссылка КАК спрШтрихкод,
	|	ПулКодовМаркировкиСУЗ.Номенклатура КАК Номенклатура,
	|	ПулКодовМаркировкиСУЗ.Характеристика КАК Характеристика,
	|	ПулКодовМаркировкиСУЗ.КодМаркировки КАК ЗначениеШтрихкода
	|ПОМЕСТИТЬ втДобавляемые
	|ИЗ
	|	РегистрСведений.ПулКодовМаркировкиСУЗ КАК ПулКодовМаркировкиСУЗ
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ДокументыЭмиссии КАК ДокументыЭмиссии
	|		ПО ПулКодовМаркировкиСУЗ.ДокументОснование = ДокументыЭмиссии.Пересортировка
	|			И ПулКодовМаркировкиСУЗ.ЗаказНаЭмиссию = ДокументыЭмиссии.ЗаказНаЭмиссию
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	|		ПО ПулКодовМаркировкиСУЗ.КодМаркировки = ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода");
	
	Запрос.УстановитьПараметр("Пересортица", Пересортица);
	Запрос.УстановитьПараметр("Эмиссия", Эмиссия);
	
	ПакетРезультатов = Запрос.ВыполнитьПакетСПромежуточнымиДанными();
	тзУбрать = ПакетРезультатов[0].Выгрузить();
	тзДобавить = ПакетРезультатов[2].Выгрузить();
	
	обУЛ = УЛ.ПолучитьОбъект();
	обШК = Агрегат.ПолучитьОбъект();
	
	Для каждого стрУбрать Из тзУбрать Цикл
		ПараметрыОтбора = Новый Структура("Штрихкод", стрУбрать["спрШтрихкод"]);
		мСтрокШК = обШК.ВложенныеШтрихкоды.НайтиСтроки(ПараметрыОтбора);
		Для каждого Эл Из мСтрокШК Цикл
			обШК.ВложенныеШтрихкоды.Удалить(Эл);
		КонецЦикла;	
		ПараметрыОтбора = Новый Структура("Номенклатура, Характеристика", 
		стрУбрать["Номенклатура"], 
		стрУбрать["Характеристика"]);
		мСтрокУЛ = обУЛ.Товары.НайтиСтроки(ПараметрыОтбора);
		Для каждого Эл Из мСтрокУЛ Цикл
			
			Если Макс(Эл["КоличествоУпаковок"], Эл["Количество"]) <= 1 Тогда
				обУЛ.Товары.Удалить(Эл);
				Продолжить;
			КонецЕсли;	
			
			Если Эл["КоличествоУпаковок"] > 1 Тогда
				Эл["КоличествоУпаковок"] = Эл["КоличествоУпаковок"] - 1;
			КонецЕсли;
			Если Эл["Количество"] > 1 Тогда
				Эл["Количество"] = Эл["Количество"] - 1;
			КонецЕсли;
		КонецЦикла;
		
				
		Набор = регистрыСведений.гф_ПересортицаУдаляемыеШК.СоздатьНаборЗаписей();
		Набор.Отбор.Пересортица.Установить(стрУбрать["Пересортица"]);
		Набор.Отбор.ШтрихкодУпаковки.Установить(стрУбрать["спрШтрихкод"]);
		Набор.Прочитать();
		Для каждого Запись Из Набор Цикл
			Запись.Обработан = Истина;
		КонецЦикла;
		Набор.Записать();
	КонецЦикла;
	Для каждого стрДобавить Из тзДобавить Цикл

		КМ = стрДобавить["спрШтрихкод"];
		Если Не ЗначениеЗаполнено(КМ) Тогда
			обНовыйШтрихКод = Справочники.ШтрихкодыУпаковокТоваров.СоздатьЭлемент();
			обНовыйШтрихКод["Номенклатура"] = стрДобавить["Номенклатура"];
			обНовыйШтрихКод["Характеристика"] = стрДобавить["Характеристика"];
			обНовыйШтрихКод["ЗначениеШтрихкода"] = стрДобавить["ЗначениеШтрихкода"];
			обНовыйШтрихКод.ТипУпаковки = Перечисления.ТипыУпаковок.МаркированныйТовар;
			обНовыйШтрихКод.ТипШтрихкода = Перечисления.ТипыШтрихкодов.GS1_DataMatrix;
			обНовыйШтрихКод.Количество = 1;
			обНовыйШтрихКод.гф_ЗначениеШтрихкодаBase64 = ШтрихкодированиеИСКлиентСервер.ШтрихкодВBase64(обНовыйШтрихКод.ЗначениеШтрихкода);
			обНовыйШтрихКод.гф_Комментарий = "Создан обработкой ""Рабочее место кладовщика""";
			обНовыйШтрихКод.Ответственный = Пользователи.АвторизованныйПользователь();
			обНовыйШтрихКод.Записать();
			КМ = обНовыйШтрихКод.Ссылка;
		КонецЕсли;
		ПараметрыОтбора = Новый Структура("Штрихкод", КМ);
		мСтрокШК = обШК.ВложенныеШтрихкоды.НайтиСтроки(ПараметрыОтбора);
		Если мСтрокШК.Количество() = 0 Тогда
			нс = обШК.ВложенныеШтрихкоды.Добавить();
			нс["Штрихкод"] = КМ;
		КонецЕсли;
		
		РеквизитыШтрихкода = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(КМ, "Номенклатура, Характеристика");
		
		ПараметрыОтбора = Новый Структура("Номенклатура, Характеристика", 
		РеквизитыШтрихкода["Номенклатура"], 
		РеквизитыШтрихкода["Характеристика"]);

		ВыборкаШтрихкодовПоРеквизитам = ПолучитьКоличествоШтрихкодовПоНоменклатуреХарактеристике(обШК, ПараметрыОтбора);
		Если ВыборкаШтрихкодовПоРеквизитам.Следующий() Тогда
			КоличествоВложенныхШтрихкодов = ВыборкаШтрихкодовПоРеквизитам["Количество"];
		Иначе
			КоличествоВложенныхШтрихкодов = 0;
		КонецЕсли;
		
		мСтрокУЛ = обУЛ.Товары.НайтиСтроки(ПараметрыОтбора);
		Если мСтрокУЛ.Количество() > 0 Тогда
			мСтрокУЛ[0]["КоличествоУпаковок"] = 
			?(мСтрокУЛ[0]["КоличествоУпаковок"] > 0 И мСтрокУЛ[0]["КоличествоУпаковок"] < КоличествоВложенныхШтрихкодов,
			мСтрокУЛ[0]["КоличествоУпаковок"] + 1, 
			мСтрокУЛ[0]["КоличествоУпаковок"]);
			
			мСтрокУЛ[0]["Количество"] = 
			?(мСтрокУЛ[0]["Количество"] > 0 И мСтрокУЛ[0]["Количество"] < КоличествоВложенныхШтрихкодов,
			мСтрокУЛ[0]["Количество"] + 1, 
			мСтрокУЛ[0]["Количество"]);
		Иначе
			Назначение = обУл.Товары[0].Назначение;
			УпаковочныйЛистРодитель = обУл.Товары[0].УпаковочныйЛистРодитель;
			нс = обУЛ.Товары.Добавить();
			ЗаполнитьЗначенияСвойств(нс, стрДобавить);
			нс["КоличествоУпаковок"] = 1;
			нс["Количество"] = 1;
			нс["Назначение"] = Назначение;
			нс["УпаковочныйЛистРодитель"] = УпаковочныйЛистРодитель;
			нс["ЭтоУпаковочныйЛист"] = Ложь;
		КонецЕсли;
		
	КонецЦикла;
	
	// удаляем запись об упаковке из Пула кодов маркировки для удаляемых штрихкодов
	КодыМаркировки = ШтрихкодированиеИСМП.НоваяТаблицаПоискаКодаМаркировкиВПуле();
	Для каждого стрУбрать Из тзУбрать Цикл
		влШтрихКод = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(стрУбрать["спрШтрихкод"], "ЗначениеШтрихкода");
		ШтрихкодированиеИСМП.ДобавитьКодМаркировкиВТаблицуДляПоискаВПуле(
		влШтрихКод,
		КодыМаркировки);
	КонецЦикла;	
	РезультатПоискаВПуле = ШтрихкодированиеИСМП.РезультатПоискаВПулеКодовМаркировки(
	КодыМаркировки,
	"ДокументОснование, ЗаказНаЭмиссию, ХешСуммаКодаМаркировки, ШтрихкодУпаковки");
	Для каждого СтрокаРезультата Из РезультатПоискаВПуле Цикл
		Набор = РегистрыСведений.ПулКодовМаркировкиСУЗ.СоздатьНаборЗаписей();
		Отбор = Набор.Отбор;
		Отбор["ДокументОснование"].Установить(СтрокаРезультата["ДокументОснование"]);
		Отбор["ЗаказНаЭмиссию"].Установить(СтрокаРезультата["ЗаказНаЭмиссию"]);
		Отбор["КодМаркировки"].Установить(СтрокаРезультата["КодМаркировки"]);
		Отбор["ХешСуммаКодаМаркировки"].Установить(СтрокаРезультата["ХешСуммаКодаМаркировки"]);
		Набор.Прочитать();
		Для каждого Запись Из Набор Цикл
			Запись["ШтрихкодУпаковки"] = Справочники.ШтрихкодыУпаковокТоваров.ПустаяСсылка();
		КонецЦикла;
		Набор.Записать();
	КонецЦикла;
	
	// для обновления записей об упаковке в Пуле кодов маркировки
	обШК.ДополнительныеСвойства.Вставить("ОбработатьВложенныеШтрихкодыВПуле", Истина);
	
	обШК.Записать();
	Если обУЛ.Проведен Тогда
		обУЛ.Записать(РежимЗаписиДокумента.Проведение);
	Иначе
		обУЛ.Записать(РежимЗаписиДокумента.Запись);
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьКоличествоШтрихкодовПоНоменклатуреХарактеристике(обАгрегат, СтруктураРеквизитов)
	
	тзВложенныеШтрихкоды = обАгрегат.ВложенныеШтрихкоды.Выгрузить();
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	т.Штрихкод КАК Штрихкод
	|ПОМЕСТИТЬ Штрихкоды
	|ИЗ
	|	&тзВложенныеШтрихкоды КАК т
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ШтрихкодыУпаковокТоваров.Номенклатура КАК Номенклатура,
	|	ШтрихкодыУпаковокТоваров.Характеристика КАК Характеристика,
	|	СУММА(1) КАК Количество
	|ИЗ
	|	Штрихкоды КАК Штрихкоды
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	|		ПО Штрихкоды.Штрихкод = ШтрихкодыУпаковокТоваров.Ссылка
	|ГДЕ
	|	ШтрихкодыУпаковокТоваров.Номенклатура = &Номенклатура
	|	И ШтрихкодыУпаковокТоваров.Характеристика = &Характеристика
	|
	|СГРУППИРОВАТЬ ПО
	|	ШтрихкодыУпаковокТоваров.Номенклатура,
	|	ШтрихкодыУпаковокТоваров.Характеристика");	
	Запрос.УстановитьПараметр("тзВложенныеШтрихкоды", тзВложенныеШтрихкоды);
	Запрос.УстановитьПараметр("Номенклатура", СтруктураРеквизитов["Номенклатура"]);
	Запрос.УстановитьПараметр("Характеристика", СтруктураРеквизитов["Характеристика"]);
	Результат= Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Возврат Выборка;
		
КонецФункции

Функция НайтиШтрикходУпаковкиТоваровИУпаковочныйЛистПоNVE(Агрегат) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ШтрихкодыУпаковокТоваров.Ссылка КАК ШтрихКодУпаковки,
	|	УпаковочныйЛист.Ссылка КАК УпаковочныйЛист
	|ИЗ
	|	Документ.УпаковочныйЛист КАК УпаковочныйЛист
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	|		ПО (УпаковочныйЛист.гф_Агрегация = ШтрихкодыУпаковокТоваров.Ссылка)
	|ГДЕ
	|	ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода = &ЗначениеШтрихкода
	|	И ШтрихкодыУпаковокТоваров.ТипУпаковки = ЗНАЧЕНИЕ(Перечисление.ТипыУпаковок.МультитоварнаяУпаковка)";
	Запрос.УстановитьПараметр("ЗначениеШтрихкода", Агрегат);
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат Неопределено;
	Иначе
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		СтруктураОтвета = Новый Структура("ШтрихКодУпаковки, УпаковочныйЛист", Выборка.ШтрихКодУпаковки, Выборка.УпаковочныйЛист);
		Возврат СтруктураОтвета;
	КонецЕсли;
	
КонецФункции
