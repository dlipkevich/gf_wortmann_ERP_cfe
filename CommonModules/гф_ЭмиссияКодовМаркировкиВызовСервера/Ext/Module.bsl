﻿
Функция гф_СоздатьЗаказНаЭмиссиюКодовМаркировки(Основание, ДополнительныеПараметры = Неопределено) Экспорт
	
	СтруктураВозврата = Новый Структура("ОписаниеОшибки,"
	+ "ЗаказНаЭмиссиюКодовМаркировкиСУЗ,"
	+ "Организация,"
	+ "ЕстьОшибкиЗаполнения,"
	+ "Статус,"
	+ "ДальнейшееДействие,"
	+ "ЗаказКодовВозможен");
	
	Если Не ЗначениеЗаполнено(Основание) Тогда
		СтруктураВозврата["ОписаниеОшибки"] = "Не заполнено основание для создания ""Заказа на эмиссию кодов маркировки""";
		Возврат СтруктураВозврата;
	КонецЕсли;
	
	Если ТипЗнч(Основание) = Тип("ДокументСсылка.ЗаказПоставщику") Тогда
		
		ДокументОснование = Основание;
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
		|	ЗаказНаЭмиссиюКодовМаркировкиСУЗ.Ссылка КАК Ссылка,
		|	ЗаказНаЭмиссиюКодовМаркировкиСУЗ.ДокументОснование КАК ДокументОснование
		|ИЗ
		|	Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК ЗаказНаЭмиссиюКодовМаркировкиСУЗ
		|ГДЕ
		|	ЗаказНаЭмиссиюКодовМаркировкиСУЗ.ДокументОснование = &ДокументОснование";
		Запрос.УстановитьПараметр("ДокументОснование", ДокументОснование);
		Результат = Запрос.Выполнить();
		Если Не Результат.Пустой() Тогда
			Выборка = Результат.Выбрать();
			Выборка.Следующий();
			СтруктураВозврата["ОписаниеОшибки"] = "Уже существует документ "
			+ Выборка["Ссылка"] + " с основанием " + Выборка["ДокументОснование"] + "
			|Документ ""Заказ на эмиссию кодов маркировки"" не создан.";
			Возврат СтруктураВозврата;
		КонецЕсли;
		
		ЗаказНаМаркировку = Документы.ЗаказНаЭмиссиюКодовМаркировкиСУЗ.СоздатьДокумент();
		Организация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокументОснование, "Организация");
		ЗаказНаМаркировку.Организация = Организация;
		ЗаказНаМаркировку.Дата = ТекущаяДатаСеанса();
		ЗаказНаМаркировку.Заполнить(ДокументОснование);
		// ++ Галфинд_ДомнышеваКР_07_06_2023
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee0501a11804d1
		// Необходимо переопределить СпособВводаВОборот
		ЗаказНаМаркировку.СпособВводаВОборот = Перечисления.СпособыВводаВОборотСУЗ.Производство;
		// -- Галфинд_ДомнышеваКР_07_06_2023
		Для каждого ТекущаяСтрока Из ЗаказНаМаркировку.Товары Цикл
			GTIN = ОпределитьГТИНПоРегиструШтрихкодыНоменклатуры(ТекущаяСтрока["Номенклатура"], ТекущаяСтрока["Характеристика"]);  
			Если ТипЗнч(GTIN) = Тип("Строка") И СтрДлина(GTIN) = 13 Тогда
				GTIN = "0" + GTIN;
			КонецЕсли;
			ТекущаяСтрока["GTIN"] = GTIN;
			РеквизитыНоменклатуры = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ТекущаяСтрока["Номенклатура"], "Код, КодТНВЭД");
			ТекущаяСтрока["КодТНВЭД"] = РеквизитыНоменклатуры["КодТНВЭД"];
			ТекущаяСтрока["Код"] = РеквизитыНоменклатуры["Код"];
		КонецЦикла;
		ЕстьОшибкиЗаполнения = ЗаказНаМаркировку.ПроверитьЗаполнение();
		Если ЕстьОшибкиЗаполнения Тогда
			
			СтруктураВозврата["ЕстьОшибкиЗаполнения"] = Истина;
			
		КонецЕсли;
		ЗаказНаМаркировку.Записать(РежимЗаписиДокумента.Проведение);
		
		СтруктураВозврата["ЗаказНаЭмиссиюКодовМаркировкиСУЗ"] = ЗаказНаМаркировку.Ссылка;
		СтруктураВозврата["Организация"] = Организация;
		ЗаполнитьДальнейшиеДействияЭмиссии(ЗаказНаМаркировку, СтруктураВозврата);
	КонецЕсли;
	
	Если ТипЗнч(Основание) = Тип("ДокументСсылка.ЗаявкаНаВозвратТоваровОтКлиента") Тогда
		
		ЗаказНаМаркировку = Документы.ЗаказНаЭмиссиюКодовМаркировкиСУЗ.СоздатьДокумент();
		Организация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Основание, "Организация");
		ЗаказНаМаркировку.Организация = Организация;
		ЗаказНаМаркировку.Дата = ТекущаяДатаСеанса();
		ЗаказНаМаркировку.Заполнить(ДокументОснование);
		// ++ Галфинд_ДомнышеваКР_13_06_2023
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee039612724d33
		// Необходимо переопределить СпособВводаВОборот
		ЗаказНаМаркировку.СпособВводаВОборот = Перечисления.СпособыВводаВОборотСУЗ.Перемаркировка;
		// -- Галфинд_ДомнышеваКР_13_06_2023
		Товары = ЗаказНаМаркировку.Товары;
		Для каждого стрТч Из ДополнительныеПараметры["ВозвращаемыеТовары"] Цикл
			Если стрТч["гф_ЗаказатьКМ"] Тогда
				нс = Товары.Добавить();
				нс["Номенклатура"] = стрТч["Номенклатура"];
				нс["Характеристика"] = стрТч["Характеристика"];
				нс["Количество"] = стрТЧ["Количество"];
				нс["КоличествоУпаковок"] = стрТч["КоличествоУпаковок"];
				нс["Шаблон"] = Перечисления.ШаблоныКодовМаркировкиСУЗ.Обувь;
				нс["СпособФормированияСерийногоНомера"] = Перечисления.СпособыФормированияСерийногоНомераСУЗ.Автоматически;
				GTIN = ОпределитьГТИНПоРегиструШтрихкодыНоменклатуры(
				стрТч["Номенклатура"], стрТч["Характеристика"]);
				Если ТипЗнч(GTIN) = Тип("Строка") И СтрДлина(GTIN) = 13 Тогда
					GTIN = "0" + GTIN;
				КонецЕсли;
				нс["GTIN"] = GTIN;
				РеквизитыНоменклатуры = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(стрТч["Номенклатура"], "Код, КодТНВЭД");
				нс["КодТНВЭД"] = РеквизитыНоменклатуры["КодТНВЭД"];
				нс["Код"] = РеквизитыНоменклатуры["Код"];
			КонецЕсли;
		КонецЦикла;
		
		ЕстьОшибкиЗаполнения = ЗаказНаМаркировку.ПроверитьЗаполнение();
		Если ЕстьОшибкиЗаполнения Тогда
			СтруктураВозврата["ЕстьОшибкиЗаполнения"] = Истина;
		КонецЕсли;
		ЗаказНаМаркировку.Записать(РежимЗаписиДокумента.Проведение);
		
		СтруктураВозврата["ЗаказНаЭмиссиюКодовМаркировкиСУЗ"] = ЗаказНаМаркировку.Ссылка;
		СтруктураВозврата["Организация"] = Организация;
		ЗаполнитьДальнейшиеДействияЭмиссии(ЗаказНаМаркировку, СтруктураВозврата);
	КонецЕсли;

	Если ТипЗнч(Основание) = Тип("ДокументСсылка.ПересортицаТоваров") Тогда
		
		ЗаказНаМаркировку = Документы.ЗаказНаЭмиссиюКодовМаркировкиСУЗ.СоздатьДокумент();
		Организация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Основание, "Организация");
		ЗаказНаМаркировку.Организация = Организация;
		ЗаказНаМаркировку.Дата = ТекущаяДатаСеанса();
		ЗаказНаМаркировку.Заполнить(ДокументОснование); 
		ЗаказНаМаркировку.ДокументОснование = Основание;
		Товары = ЗаказНаМаркировку.Товары;
		Для каждого стрТч Из ДополнительныеПараметры["Товары"] Цикл
				нс = Товары.Добавить();
				нс["Номенклатура"] = стрТч["Номенклатура"];
				нс["Характеристика"] = стрТч["Характеристика"];
				нс["Количество"] = 1;
				нс["КоличествоУпаковок"] = 1;
				нс["Шаблон"] = Перечисления.ШаблоныКодовМаркировкиСУЗ.Обувь;
				нс["СпособФормированияСерийногоНомера"] = Перечисления.СпособыФормированияСерийногоНомераСУЗ.Автоматически;
				GTIN = ОпределитьГТИНПоРегиструШтрихкодыНоменклатуры(стрТч["Номенклатура"], стрТч["Характеристика"]);  
				Если ТипЗнч(GTIN) = Тип("Строка") И СтрДлина(GTIN) = 13 Тогда
					GTIN = "0" + GTIN;
				КонецЕсли;
				нс["GTIN"] = GTIN;
				РеквизитыНоменклатуры = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(стрТч["Номенклатура"], "Код, КодТНВЭД");
				нс["КодТНВЭД"] = РеквизитыНоменклатуры["КодТНВЭД"];
				нс["Код"] = РеквизитыНоменклатуры["Код"];
		КонецЦикла;
		
		ЕстьОшибкиЗаполнения = ЗаказНаМаркировку.ПроверитьЗаполнение();
		Если ЕстьОшибкиЗаполнения Тогда
			СтруктураВозврата["ЕстьОшибкиЗаполнения"] = Истина;
		КонецЕсли;
		ЗаказНаМаркировку.Записать(РежимЗаписиДокумента.Проведение);
		
		СтруктураВозврата["ЗаказНаЭмиссиюКодовМаркировкиСУЗ"] = ЗаказНаМаркировку.Ссылка;
		СтруктураВозврата["Организация"] = Организация;
		ЗаполнитьДальнейшиеДействияЭмиссии(ЗаказНаМаркировку, СтруктураВозврата);
	КонецЕсли;		

	Если ТипЗнч(Основание) = Тип("ДокументСсылка.ПриобретениеТоваровУслуг") Тогда
		
		ЗаказНаМаркировку = Документы.ЗаказНаЭмиссиюКодовМаркировкиСУЗ.СоздатьДокумент();
		ЗаказНаМаркировку.ДокументОснование = Основание;
		Организация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Основание, "Организация");
		ЗаказНаМаркировку.Организация = Организация;
		ЗаказНаМаркировку.Дата = ТекущаяДатаСеанса();
		ЗаказНаМаркировку.Заполнить(ДокументОснование);
		ЗаказНаМаркировку.СпособВводаВОборот = Перечисления.СпособыВводаВОборотСУЗ.Импорт;
		Товары = ЗаказНаМаркировку.Товары;
		Для каждого стрТч Из ДополнительныеПараметры["Товары"] Цикл
			нс = Товары.Добавить();
			нс["Номенклатура"] = стрТч["Номенклатура"];
			нс["Характеристика"] = стрТч["Характеристика"];
			нс["Количество"] = стрТЧ["Количество"];
			нс["КоличествоУпаковок"] = стрТч["КоличествоУпаковок"];
			нс["Шаблон"] = Перечисления.ШаблоныКодовМаркировкиСУЗ.Обувь;
			нс["СпособФормированияСерийногоНомера"] = Перечисления.СпособыФормированияСерийногоНомераСУЗ.Автоматически;
			GTIN = ОпределитьГТИНПоРегиструШтрихкодыНоменклатуры(стрТч["Номенклатура"], стрТч["Характеристика"]);  
			Если ТипЗнч(GTIN) = Тип("Строка") И СтрДлина(GTIN) = 13 Тогда
				GTIN = "0" + GTIN;
			КонецЕсли;
			нс["GTIN"] = GTIN;
			РеквизитыНоменклатуры = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(стрТч["Номенклатура"], "Код, КодТНВЭД");
			нс["КодТНВЭД"] = РеквизитыНоменклатуры["КодТНВЭД"];
			нс["Код"] = РеквизитыНоменклатуры["Код"];
		КонецЦикла;
		
		ЕстьОшибкиЗаполнения = ЗаказНаМаркировку.ПроверитьЗаполнение();
		Если ЕстьОшибкиЗаполнения Тогда
			СтруктураВозврата["ЕстьОшибкиЗаполнения"] = Истина;
		КонецЕсли;
		ЗаказНаМаркировку.Записать(РежимЗаписиДокумента.Проведение);
		
		СтруктураВозврата["ЗаказНаЭмиссиюКодовМаркировкиСУЗ"] = ЗаказНаМаркировку.Ссылка;
		СтруктураВозврата["Организация"] = Организация;
		ЗаполнитьДальнейшиеДействияЭмиссии(ЗаказНаМаркировку, СтруктураВозврата);
	КонецЕсли;		
	
	Если ТипЗнч(Основание) = Тип("Структура")  Тогда
		Если ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Основание, "Источник")  = 
			"Обработка_гф_РабочееМестоКладовщика" Тогда
			
			Запрос = Новый Запрос("ВЫБРАТЬ
			|	ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода КАК ЗначениеШтрихкода
			|ПОМЕСТИТЬ ЗначенияШтрихкодов
			|ИЗ
			|	Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
			|ГДЕ
			|	ШтрихкодыУпаковокТоваров.Ссылка В(&КМ)
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	ПулКодовМаркировкиСУЗ.ЗаказНаЭмиссию КАК ЗаказНаЭмиссию
			|ИЗ
			|	РегистрСведений.ПулКодовМаркировкиСУЗ КАК ПулКодовМаркировкиСУЗ
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ЗначенияШтрихкодов КАК Штрихкоды
			|		ПО ПулКодовМаркировкиСУЗ.КодМаркировки = Штрихкоды.ЗначениеШтрихкода");
			
			ТоварыУбрать = Основание["ТоварыУбрать"];
			МассивКМ = ТоварыУбрать.ВыгрузитьКолонку("КМ");
			Запрос.УстановитьПараметр("КМ", МассивКМ);
			Результат = Запрос.Выполнить();
			Если Результат.Пустой() Тогда
				СтруктураВозврата["ОписаниеОшибки"] = 
				"Не найдено основание для создания ""Заказа на эмиссию кодов маркировки""";
				Возврат СтруктураВозврата;
			КонецЕсли;
			Выборка = Результат.Выбрать();
			Выборка.Следующий();
			ТоварыДобавить = Основание["ТоварыДобавить"];
			
			ОписаниеТипаЧисло = Новый ОписаниеТипов("Число",
			Новый КвалификаторыЧисла(0, 0, ДопустимыйЗнак.Любой));
			
			ТоварыДобавить.Колонки.Добавить("Количество", ОписаниеТипаЧисло);
			ТоварыДобавить.Колонки.Добавить("КоличествоУпаковок", ОписаниеТипаЧисло);
			ТоварыДобавить.ЗаполнитьЗначения(1, "Количество, КоличествоУпаковок");
			ТоварыДобавить.Свернуть("Номенклатура, Характеристика", "Количество, КоличествоУпаковок");
			
			ЗаказНаМаркировку = Выборка["ЗаказНаЭмиссию"].Скопировать();
			ЗаказНаМаркировку.СерийныеНомера.Очистить();
			ЗаказНаМаркировку.Товары.Очистить();
			ЗаказНаМаркировку.Дата = ТекущаяДатаСеанса();
			ЗаказНаМаркировку.Ответственный = Пользователи.АвторизованныйПользователь();
			
			Товары = ЗаказНаМаркировку.Товары;
			
			Для каждого СтрокаТЗ Из ТоварыДобавить Цикл
				нс = Товары.Добавить();
				ЗаполнитьЗначенияСвойств(нс, СтрокаТЗ);
			КонецЦикла;
			
			//ЗаказНаМаркировку.Заполнить(Основание);
			Для каждого ТекущаяСтрока Из ЗаказНаМаркировку.Товары Цикл
				массивGNIN = ИнтеграцияИСМП.МассивЗначенийGTINДляВыбора(ТекущаяСтрока, ЗаказНаМаркировку, Ложь);
				Если ТипЗнч(массивGNIN) = Тип("Массив") И массивGNIN.ВГраница() > -1 Тогда
					ТекущаяСтрока["GTIN"] = массивGNIN[0];
				КонецЕсли;
				ТекущаяСтрока["СпособФормированияСерийногоНомера"] = Перечисления.СпособыФормированияСерийногоНомераСУЗ.Автоматически;
			КонецЦикла;
			
			ЕстьОшибкиЗаполнения = ЗаказНаМаркировку.ПроверитьЗаполнение();
			Если ЕстьОшибкиЗаполнения Тогда
				СтруктураВозврата["ЕстьОшибкиЗаполнения"] = Истина;
			КонецЕсли;
			ЗаказНаМаркировку.Записать(РежимЗаписиДокумента.Проведение);
			
			СтруктураВозврата["ЗаказНаЭмиссиюКодовМаркировкиСУЗ"] = ЗаказНаМаркировку.Ссылка;
			СтруктураВозврата["Организация"] = Организация;
			
			ЗаполнитьДальнейшиеДействияЭмиссии(ЗаказНаМаркировку, СтруктураВозврата);
		КонецЕсли;
	КонецЕсли;
	
	Возврат СтруктураВозврата;
	
КонецФункции

Процедура ЗаполнитьДальнейшиеДействияЭмиссии(ЗаказНаМаркировку, СтруктураВозврата) Экспорт

	МенеджерОбъекта = ИнтеграцияИС.МенеджерОбъектаПоСсылке(ЗаказНаМаркировку.Ссылка);
		Статус = МенеджерОбъекта.СтатусПоУмолчанию();
		СтруктураПараметров = Новый Структура;
		СтруктураПараметров.Вставить("ОбъектРасчета", ЗаказНаМаркировку);
		ДопустимыеДействия = МенеджерОбъекта.ДопустимыеДействия(ЗаказНаМаркировку);
		Если ЗначениеЗаполнено(ЗаказНаМаркировку.Ссылка) Тогда
			
			Запрос = Новый Запрос(
			"ВЫБРАТЬ
			|	Статусы.Статус КАК Статус,
			|	ВЫБОР
			|		КОГДА Статусы.ДальнейшееДействие1 В (&МассивДальнейшиеДействия)
			|			ТОГДА ЗНАЧЕНИЕ(Перечисление.ДальнейшиеДействияПоВзаимодействиюИСМП.НеТребуется)
			|		ИНАЧЕ Статусы.ДальнейшееДействие1
			|	КОНЕЦ КАК ДальнейшееДействие1,
			|	ВЫБОР
			|		КОГДА Статусы.ДальнейшееДействие2 В (&МассивДальнейшиеДействия)
			|			ТОГДА ЗНАЧЕНИЕ(Перечисление.ДальнейшиеДействияПоВзаимодействиюИСМП.НеТребуется)
			|		ИНАЧЕ Статусы.ДальнейшееДействие2
			|	КОНЕЦ КАК ДальнейшееДействие2,
			|	ВЫБОР
			|		КОГДА Статусы.ДальнейшееДействие3 В (&МассивДальнейшиеДействия)
			|			ТОГДА ЗНАЧЕНИЕ(Перечисление.ДальнейшиеДействияПоВзаимодействиюИСМП.НеТребуется)
			|		ИНАЧЕ Статусы.ДальнейшееДействие3
			|	КОНЕЦ КАК ДальнейшееДействие3
			|ИЗ
			|	РегистрСведений.СтатусыДокументовИСМП КАК Статусы
			|ГДЕ
			|	Статусы.Документ = &Документ");
			
			Запрос.УстановитьПараметр("Документ", ЗаказНаМаркировку.Ссылка);
			Запрос.УстановитьПараметр(
			"МассивДальнейшиеДействия", ИнтеграцияИСМП.НеотображаемыеВДокументахДальнейшиеДействия());
			
			Выборка = Запрос.Выполнить().Выбрать();
			
			Если Выборка.Следующий() Тогда
				
				Статус = Выборка.Статус;
				
				ДальнейшееДействие = Новый Массив;
				
				ДальнейшиеДействияРегистр = Новый Массив;
				ДальнейшиеДействияРегистр.Добавить(Выборка.ДальнейшееДействие1);
				ДальнейшиеДействияРегистр.Добавить(Выборка.ДальнейшееДействие2);
				ДальнейшиеДействияРегистр.Добавить(Выборка.ДальнейшееДействие3);
				
				Для Каждого ДальнейшееДействиеРегиср Из ДальнейшиеДействияРегистр Цикл
					
					ДобавляемоеДействие = ДальнейшееДействиеРегиср;
					Если ДопустимыеДействия.Найти(ДобавляемоеДействие) = Неопределено Тогда
						Если ДобавляемоеДействие =
							Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.ЗапроситеGTINНаОстатки Тогда
							ДобавляемоеДействие = Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.ЗапроситеКодыМаркировки;
						ИначеЕсли ДобавляемоеДействие =
							Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.ЗапроситеКодыМаркировки Тогда
							ДобавляемоеДействие = Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.ЗапроситеGTINНаОстатки;
						КонецЕсли;
					КонецЕсли;
					
					Если ДальнейшееДействие.Найти(ДобавляемоеДействие) = Неопределено Тогда
						ДальнейшееДействие.Добавить(ДобавляемоеДействие);
					КонецЕсли;
					
				КонецЦикла;
				
			КонецЕсли;
			
		Иначе
			ДальнейшееДействие = МенеджерОбъекта.ДальнейшееДействиеПоУмолчанию(СтруктураПараметров);
		КонецЕсли;
		
		СтруктураВозврата["Статус"] = Статус;
		Если ДальнейшееДействие.ВГраница() > -1  Тогда
			СтруктураВозврата["ДальнейшееДействие"] = ДальнейшееДействие[0];
		КонецЕсли;
		
		Если Статус = Перечисления.СтатусыОбработкиЗаказовНаЭмиссиюКодовМаркировкиИСМП.Черновик 
			И (ДальнейшееДействие.ВГраница() > -1 
			И ДальнейшееДействие[0] = Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.ЗапроситеКодыМаркировки)
			И (ДопустимыеДействия.ВГраница() > -1 
			И ДопустимыеДействия.Найти(Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.ЗапроситеКодыМаркировки) <> Неопределено)  Тогда
			
			СтруктураВозврата["ЗаказКодовВозможен"] = Истина;
		КонецЕсли;

КонецПроцедуры

Функция СоздатьДокументМаркировкиТоваров(Товары, ЗаказНаЭмиссию, NVE) Экспорт
	
	мКМ = Товары.ВыгрузитьКолонку("КМ");

	Запрос = Новый Запрос("ВЫБРАТЬ
	|	ШтрихкодыУпаковокТоваров.Ссылка КАК Ссылка
	|ПОМЕСТИТЬ Штрихкоды
	|ИЗ
	|	Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	|ГДЕ
	|	ШтрихкодыУпаковокТоваров.Ссылка В(&КМ)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	МаркировкаТоваровИСМПШтрихкодыУпаковок.Ссылка КАК ДокументМаркировки
	|ИЗ
	|	Документ.МаркировкаТоваровИСМП.ШтрихкодыУпаковок КАК МаркировкаТоваровИСМПШтрихкодыУпаковок
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Штрихкоды КАК Штрихкоды
	|		ПО МаркировкаТоваровИСМПШтрихкодыУпаковок.ШтрихкодУпаковки = Штрихкоды.Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	ВложенныйЗапрос.Склад КАК Склад
	|ИЗ
	|	(ВЫБРАТЬ
	|		ВЫБОР
	|			КОГДА РасходныйОрдерНаТовары.Ссылка ЕСТЬ НЕ NULL 
	|				ТОГДА РасходныйОрдерНаТовары.Склад
	|			ИНАЧЕ NULL
	|		КОНЕЦ КАК Склад
	|	ИЗ
	|		Документ.УпаковочныйЛист КАК УпаковочныйЛист
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.РасходныйОрдерНаТовары КАК РасходныйОрдерНаТовары
	|			ПО УпаковочныйЛист.гф_Поставка = РасходныйОрдерНаТовары.Ссылка
	|	ГДЕ
	|		УпаковочныйЛист.Код = &NVE
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		ВЫБОР
	|			КОГДА ПриобретениеТоваровУслуг.Ссылка ЕСТЬ НЕ NULL 
	|				ТОГДА ПриобретениеТоваровУслуг.Склад
	|			ИНАЧЕ NULL
	|		КОНЕЦ
	|	ИЗ
	|		Документ.УпаковочныйЛист КАК УпаковочныйЛист
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПриобретениеТоваровУслуг КАК ПриобретениеТоваровУслуг
	|			ПО УпаковочныйЛист.гф_Поставка = ПриобретениеТоваровУслуг.Ссылка
	|	ГДЕ
	|		УпаковочныйЛист.Код = &NVE) КАК ВложенныйЗапрос
	|ГДЕ
	|	ВложенныйЗапрос.Склад ЕСТЬ НЕ NULL
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|
	|ВЫБРАТЬ
	|	ПулКодов.Номенклатура КАК Номенклатура,
	|	ПулКодов.Характеристика КАК Характеристика,
	|	ПулКодов.ШтрихкодУпаковки КАК ШтрихкодУпаковки,
	|	ПулКодов.КодМаркировки КАК КодМаркировки
	|ИЗ
	|	РегистрСведений.ПулКодовМаркировкиСУЗ КАК ПулКодов
	|ГДЕ
	|	ПулКодов.ЗаказНаЭмиссию = &ЗаказНаЭмиссию");
	
	Запрос.УстановитьПараметр("КМ", мКМ);
	Запрос.УстановитьПараметр("NVE", NVE);
	Запрос.УстановитьПараметр("ЗаказНаЭмиссию", ЗаказНаЭмиссию);
	
	ПакетРезультатов = Запрос.ВыполнитьПакет();
	РезультатДокументМаркировки = ПакетРезультатов[1];
	РезультатСклады = ПакетРезультатов[2];
	РезультатШтрихкоды = ПакетРезультатов[3];
	Если РезультатДокументМаркировки.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	Если РезультатШтрихкоды.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	Выборка = РезультатДокументМаркировки.Выбрать();
	Выборка.Следующий();
	ДокументМаркировки = Выборка["ДокументМаркировки"].Скопировать();
	ДокументМаркировки.Дата = ТекущаяДатаСеанса();
	ДокументМаркировки.Ответственный = Пользователи.АвторизованныйПользователь();
	ДокументМаркировки.Товары.Очистить();
	ДокументМаркировки.ШтрихкодыУпаковок.Очистить();
	Если Не РезультатСклады.Пустой() Тогда
		ВыборкаСклады = РезультатСклады.Выбрать();
		ВыборкаСклады.Следующий();
		Если ЗначениеЗаполнено(ВыборкаСклады["Склад"]) Тогда
			ДокументМаркировки.ДополнительныеСвойства.Вставить("Склад", ВыборкаСклады["Склад"]);
		КонецЕсли;
	КонецЕсли;
	ВыборкаШтрихкоды = РезультатШтрихкоды.Выбрать();
	Пока ВыборкаШтрихкоды.Следующий() Цикл
		стрШтрихкоды = ДокументМаркировки.ШтрихкодыУпаковок.Добавить();
		стрШтрихкоды.ШтрихкодУпаковки = ВыборкаШтрихкоды["ШтрихкодУпаковки"];
		стрТовары = ДокументМаркировки.Товары.Добавить();
		ЗаполнитьЗначенияСвойств(стрТовары, ВыборкаШтрихкоды);
		стрТовары["Количество"] = 1;
		стрТовары["КоличествоУпаковок"] = 1;
	КонецЦикла;
	
	ДокументМаркировки.Записать(РежимЗаписиДокумента.Проведение);
	
	Возврат ДокументМаркировки.Ссылка;
	
КонецФункции

Функция ОпределитьГТИНПоРегиструШтрихкодыНоменклатуры(Номенклатура, Характеристика)
	
	Штрихкод = "";
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	ШтрихкодыНоменклатуры.Штрихкод КАК Штрихкод
	|ИЗ
	|	РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
	|ГДЕ
	|	ШтрихкодыНоменклатуры.Номенклатура = &Номенклатура
	|	И ШтрихкодыНоменклатуры.Характеристика = &Характеристика");
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("Характеристика", Характеристика);
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Штрихкод;
	КонецЕсли;
	Выборка = Результат.Выбрать();
	Выборка.Следующий();
	Возврат Выборка["Штрихкод"];
	
КонецФункции // ()

//Параметры:
// МассивВходящихДанных - массив ссылок Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ
// ЗаказКодовВозможен - булево значение по-умолчанию (СадомцевСА 23.05.2023)
Процедура гф_ПодготовитьКПередачеИСМП(МассивВходящихДанных, ЗаказКодовВозможен = Ложь) Экспорт
	
	Если Не ПолучитьФункциональнуюОпцию("ИспользоватьАвтоматическуюОтправкуПолучениеДанныхИСМП") Тогда
		Возврат;
	КонецЕсли;
	
	ВходящиеДанные = Новый Массив;
	Для каждого Эл Из МассивВходящихДанных Цикл
		СтруктураПроверки = ПолучитьСтруктуруПроверки();
		ЗаполнитьДальнейшиеДействияЭмиссии(Эл, СтруктураПроверки);
		// ++ СадомцевСА 23.05.2023
		Если СтруктураПроверки["ЗаказКодовВозможен"] = Неопределено Тогда
			СтруктураПроверки["ЗаказКодовВозможен"] = ЗаказКодовВозможен;
		КонецЕсли;
		// -- СадомцевСА 23.05.2023
		Если СтруктураПроверки["ЗаказКодовВозможен"] Тогда
			
			ПараметрыОбработкиДокументов = ИнтеграцияИСМПСлужебныйКлиентСервер.ПараметрыОбработкиДокументов();
			ПараметрыОбработкиДокументов.Ссылка = Эл;
			Организация = ОбщегоНазначенияУТВызовСервера.ЗначениеРеквизитаОбъекта(Эл, "Организация");
			ПараметрыОбработкиДокументов.Организация = Организация;
			ПараметрыОбработкиДокументов.ДальнейшееДействие = ПредопределенноеЗначение(
			"Перечисление.ДальнейшиеДействияПоВзаимодействиюИСМП.ЗапроситеКодыМаркировки");
			ВходящиеДанные.Добавить(ПараметрыОбработкиДокументов);
		КонецЕсли;
	КонецЦикла;
		
	РезультатОбмена = ИнтеграцияИСМПВызовСервера.ПодготовитьКПередаче(ВходящиеДанные);
	
	// ++ СадомцевСА 07.06.2023 Для каждого документа делаю еще одну запись в регистре Очередь сообщений
	// по аналогии с документами Маркировка товаров
	//e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee038fabff86c0
	Если РезультатОбмена.Свойство("ПараметрыОбмена") Тогда
		СвойстваПодписи = гф_ЭлектроннаяПодписьВызовСервера.ПолучитьЗначениеКонстанты();
		Если ТипЗнч(СвойстваПодписи) <> Тип("Структура") Тогда
			Возврат;
		КонецЕсли;
		Если РезультатОбмена.ПараметрыОбмена.СообщенияКПодписанию = Неопределено Тогда
			Возврат;
		КонецЕсли;
		// Галфинд СадомцевСА 04.08.2023 Исправил "ошибку" СонарКуба
		гф_ДополнитьОчередьСообщений(РезультатОбмена, СвойстваПодписи);
	КонецЕсли;
	// -- СадомцевСА 07.06.2023

КонецПроцедуры

Функция ПолучитьСтруктуруПроверки()
	СтруктураВозврата = Новый Структура(
	"Статус,"
	+ "ДальнейшееДействие,"
	+ "ЗаказКодовВозможен");
	Возврат СтруктураВозврата;
КонецФункции

Процедура ПроверитьСоздатьЭлементыМаркированныйТовар() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	ЗНАЧЕНИЕ(Перечисление.ТипыУпаковок.МаркированныйТовар) КАК ТипУпаковки,
	|	ЗНАЧЕНИЕ(Перечисление.ТипыШтрихкодов.GS1_DataMatrix) КАК ТипШтрихкода,
	// vvv Галфинд \ Sakovich 18.07.2023
	|	ЗНАЧЕНИЕ(Перечисление.гф_СтатусыКМ_в_ШК.Эмитирован) КАК гф_Статус,
	// ^^^ Галфинд \ Sakovich 18.07.2023 	
	|	1 КАК Количество,
	|	ПулКодовМаркировкиСУЗ.КодМаркировки КАК ЗначениеШтрихкода,
	|	ПулКодовМаркировкиСУЗ.Номенклатура КАК Номенклатура,
	|	ПулКодовМаркировкиСУЗ.Характеристика КАК Характеристика,
	// #wortmann { 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee224d0352ee32 
	// Галфинд_Домнышева 2023/07/18
	|	ПулКодовМаркировкиСУЗ.ДокументОснование КАК гф_ДокументОснование,
	|	ПулКодовМаркировкиСУЗ.ПолныйКодМаркировки КАК гф_ПолныйКодМаркировки,
	// } #wortmann
	|	ПулКодовМаркировкиСУЗ.ЗаказНаЭмиссию КАК ЗаказНаЭмиссию
	|ИЗ
	|	РегистрСведений.ПулКодовМаркировкиСУЗ КАК ПулКодовМаркировкиСУЗ
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	|		ПО (ПулКодовМаркировкиСУЗ.КодМаркировки = ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода)
	|ГДЕ
	|	ШтрихкодыУпаковокТоваров.Ссылка ЕСТЬ NULL
	|ИТОГИ ПО
	|	ЗаказНаЭмиссию";
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	ВыборкаЗаказы = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаЗаказы.Следующий() Цикл
		ВсеШтрихкодыОбработаны = Истина;
		ВыборкаШтрихКод = ВыборкаЗаказы.Выбрать();
		Пока ВыборкаШтрихКод.Следующий() Цикл
			обШК = Справочники.ШтрихкодыУпаковокТоваров.СоздатьЭлемент();
			ЗаполнитьЗначенияСвойств(обШК, ВыборкаШтрихКод);
			Попытка
				обШК.Записать();
			Исключение
				ВсеШтрихкодыОбработаны = Ложь;
				ТекстОшибки = ОписаниеОшибки();
				СтрокаСообщения = "Не удалось записать элемент справочника ""Штрихкоды упаковок товары""
				|со значением штрихкода "+ ВыборкаШтрихКод["ЗначениеШтрихкода"] +" Ошибка: " + ТекстОшибки;
				
				ЗаписьЖурналаРегистрации("Справочник.ШтрихкодыУпаковокТоваров.ОшибкаЗаписи", 
				УровеньЖурналаРегистрации.Информация, , , СтрокаСообщения);
			КонецПопытки;
			
			// vvv Галфинд \ Sakovich 18.07.2023
			ШКСсылка = обШК.Ссылка;
			Если Не ШКСсылка.Пустая() Тогда
				ПериодЗаписи = ТекущаяДатаСеанса();
				Попытка
					ЗаписатьИсторияСтатусовКМ(ПериодЗаписи, ШКСсылка, Перечисления.гф_СтатусыКМ_в_ШК.Эмитирован, ВыборкаЗаказы["ЗаказНаЭмиссию"]);
				Исключение
					ТекстОшибки = ОписаниеОшибки();
					СтрокаСообщения = "Не удалось записать статус для элемента справочника ""Штрихкоды упаковок товары""
					|со значением штрихкода "+ ВыборкаШтрихКод["ЗначениеШтрихкода"] +" Ошибка: " + ТекстОшибки;
					
					ЗаписьЖурналаРегистрации("РегистрСведений.гф_ИсторияСтатусовКМ.ОшибкаЗаписи", 
					УровеньЖурналаРегистрации.Информация, , , СтрокаСообщения);
				КонецПопытки;	
			КонецЕсли;
			// ^^^ Галфинд \ Sakovich 18.07.2023
		КонецЦикла;
		Если ВсеШтрихкодыОбработаны Тогда
			
			обЗаказНаЭмиссию = ВыборкаЗаказы["ЗаказНаЭмиссию"].ПолучитьОбъект();
			Если обЗаказНаЭмиссию <> Неопределено Тогда
				Попытка
					обЗаказНаЭмиссию.Записать(РежимЗаписиДокумента.Проведение);
				Исключение
					ТекстОшибки = ОписаниеОшибки();
					СтрокаСообщения = "Не удалось провести документ "+ ВыборкаЗаказы["ЗаказНаЭмиссию"] +
					" Ошибка: " + ТекстОшибки;
					ЗаписьЖурналаРегистрации("Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ.ОшибкаЗаписи", 
					УровеньЖурналаРегистрации.Информация, , , СтрокаСообщения);
				КонецПопытки;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;	
КонецПроцедуры

// #wortmann {
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee119532727cd1
// Галфинд ДомнышеваКР_23_06_2023
// При изменении статуса у документа "Заказ на эмиссию кодов маркировки СУЗ ИСМП" на "Коды маркировки эмитированы"
// распоряжение которого является "Пересортица товаров" необходимо запускать "Генерация элементов маркированный товар".
// Параметры:
// Параметры:
//  Источник - РегистрСведенийНаборЗаписей.СтатусыДокументовИСМП - Набор записей регистра сведений
//  Отказ - Булево - Признак отказа от записи
//  Замещение - Булево - Замещение
//
Процедура гф_СтатусыДокументовИСМППриЗаписиПоПереоценкеПриЗаписи(Источник, Отказ, Замещение) Экспорт
	
	Для каждого Запись Из Источник Цикл
		Если ТипЗнч(Запись.Документ) = Тип("ДокументСсылка.ЗаказНаЭмиссиюКодовМаркировкиСУЗ")
			И ТипЗнч(Запись.Документ.ДокументОснование) = Тип("ДокументСсылка.ПересортицаТоваров")
			И Запись.Статус = Перечисления.СтатусыОбработкиЗаказовНаЭмиссиюКодовМаркировкиИСМП.СУЗКодыМаркировкиЭмитированы Тогда
			
			гф_ЭмиссияКодовМаркировкиВызовСервера.ПроверитьСоздатьЭлементыМаркированныйТовар();
			Прервать;	
		КонецЕсли;
	КонецЦикла; 

КонецПроцедуры// } #wortmann 

// #wortmann {
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee0441749bccbe
// Галфинд Sakovich 2023/07/18
Процедура ЗаписатьИсторияСтатусовКМ(Период, ШтрихкодУпаковки, СтатусКМ, Документ) Экспорт
	
	Набор = РегистрыСведений.гф_ИсторияСтатусовКМ.СоздатьНаборЗаписей();
	Набор.Отбор.ШтрихкодУпаковки.Установить(ШтрихкодУпаковки);
	Набор.Отбор.Период.Установить(Период);
	Запись = Набор.Добавить();
	Запись["Период"] = Период;
	Запись["ШтрихкодУпаковки"] = ШтрихкодУпаковки;
	Запись["СтатусКМ"] = СтатусКМ;
	Запись["Документ"] = Документ;
	Набор.Записать();
	
КонецПроцедуры // } #wortmann

// #wortmann {
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee0441749bccbe
// Галфинд Sakovich 2023/07/18
Процедура гф_СтатусыДокументовИСМППриЗаписи(Источник, Отказ, Замещение) Экспорт
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	Если Источник.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для каждого Запись Из Источник Цикл
		Период = ТекущаяДатаСеанса();
		Если ТипЗнч(Запись.Документ) = Тип("ДокументСсылка.ЗаказНаЭмиссиюКодовМаркировкиСУЗ")
			И Запись.Статус = Перечисления.СтатусыОбработкиЗаказовНаЭмиссиюКодовМаркировкиИСМП.СУЗКодыМаркировкиЭмитированы 
			И Запись.ДальнейшееДействие1 = Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.НеТребуется Тогда
			
			ЗаказНаЭмиссию = Источник.Отбор["Документ"]["Значение"];
			
			Запрос = Новый Запрос;
			Запрос.Текст = "
			|ВЫБРАТЬ
			|	ШтрихкодыУпаковокТоваров.Ссылка КАК ШтрихкодУпаковки,
			|	ЗНАЧЕНИЕ(Перечисление.гф_СтатусыКМ_в_ШК.Эмитирован) КАК СтатусКМ,
			|	ПулКодовМаркировкиСУЗ.ЗаказНаЭмиссию КАК Документ
			|ИЗ
			|	РегистрСведений.ПулКодовМаркировкиСУЗ КАК ПулКодовМаркировкиСУЗ
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
			|		ПО (ПулКодовМаркировкиСУЗ.КодМаркировки = ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода)
			|ГДЕ
			|	ПулКодовМаркировкиСУЗ.ЗаказНаЭмиссию = &ЗаказНаЭмиссию
			|	И ШтрихкодыУпаковокТоваров.Ссылка ЕСТЬ НЕ NULL";
			Запрос.УстановитьПараметр("ЗаказНаЭмиссию", ЗаказНаЭмиссию);
			Результат = Запрос.Выполнить();
			Если Результат.Пустой() Тогда
				Возврат;
			КонецЕсли;
			Выборка = Результат.Выбрать();
			Пока Выборка.Следующий() Цикл
				обШК = Выборка["ШтрихкодУпаковки"].ПолучитьОбъект();
				Если обШК <> Неопределено Тогда
					обШК.гф_Статус = Выборка["СтатусКМ"];
				КонецЕсли;
				обШК.Записать();
				ЗаписатьИсторияСтатусовКМ(Период, Выборка["ШтрихкодУпаковки"], Выборка["СтатусКМ"], Выборка["Документ"]);
			КонецЦикла;
		КонецЕсли;
		
		Если ТипЗнч(Запись.Документ) = Тип("ДокументСсылка.МаркировкаТоваровИСМП")
			И Запись.Статус = Перечисления.СтатусыОбработкиМаркировкиТоваровИСМП.КодыМаркировкиВведеныВОборот
			И (Запись.ДальнейшееДействие1 = Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.НеТребуется
			Или Запись.ДальнейшееДействие1 = Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.ВыполнитеАгрегацию) Тогда
			
			докМаркировка = Запись.Документ;
			Операция = докМаркировка["Операция"];
			Если ЭтоОперацияВводаВОборот(Операция) Тогда
				СтатусВОбороте = Перечисления.гф_СтатусыКМ_в_ШК.ВОбороте;
				Для каждого стрШК Из докМаркировка.ШтрихкодыУпаковок Цикл
					Если ЗначениеЗаполнено(стрШК["ШтрихкодУпаковки"]) 
						И стрШК["ШтрихкодУпаковки"]["ТипУпаковки"] = Перечисления.ТипыУпаковок.МаркированныйТовар Тогда
						обШК = стрШК["ШтрихкодУпаковки"].ПолучитьОбъект();
						Если обШК <> Неопределено Тогда
							обШК.гф_Статус = СтатусВОбороте;
							обШК.Записать();
							ЗаписатьИсторияСтатусовКМ(Период, стрШК["ШтрихкодУпаковки"], СтатусВОбороте, докМаркировка);
						КонецЕсли;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
		
		Если ТипЗнч(Запись.Документ) = Тип("ДокументСсылка.ПеремаркировкаТоваровИСМП")
			И Запись.Статус = Перечисления.СтатусыОбработкиПеремаркировкиТоваровИСМП.ПеремаркировкаВыполнена
			И Запись.ДальнейшееДействие1 = Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.НеТребуется Тогда
			
			докПеремаркировка = Запись.Документ;
			СтатусПеремаркирован = Перечисления.гф_СтатусыКМ_в_ШК.Перемаркирован;
			СтатусВОбороте = Перечисления.гф_СтатусыКМ_в_ШК.ВОбороте;
			
			Для каждого стрТовары Из докПеремаркировка.Товары Цикл
				
				Если ЗначениеЗаполнено(стрТовары["КодМаркировки"])
					И стрТовары["КодМаркировки"]["ТипУпаковки"] = Перечисления.ТипыУпаковок.МаркированныйТовар Тогда
					обШК = стрТовары["КодМаркировки"].ПолучитьОбъект();
					Если обШК <> Неопределено Тогда
						обШК.гф_Статус = СтатусПеремаркирован;
						обШК.Записать();
						ЗаписатьИсторияСтатусовКМ(Период, стрТовары["КодМаркировки"], СтатусПеремаркирован, докПеремаркировка);
					КонецЕсли;
				КонецЕсли;
				
				Если ЗначениеЗаполнено(стрТовары["НовыйКодМаркировки"])
					И стрТовары["НовыйКодМаркировки"]["ТипУпаковки"] = Перечисления.ТипыУпаковок.МаркированныйТовар Тогда
					обШК = стрТовары["НовыйКодМаркировки"].ПолучитьОбъект();
					Если обШК <> Неопределено Тогда
						обШК.гф_Статус = СтатусВОбороте;
						обШК.Записать();
						ЗаписатьИсторияСтатусовКМ(Период, стрТовары["НовыйКодМаркировки"], СтатусВОбороте, докПеремаркировка);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		Если ТипЗнч(Запись.Документ) = Тип("ДокументСсылка.ВыводИзОборотаИСМП")
			И Запись.Статус = Перечисления.СтатусыОбработкиВыводаИзОборотаИСМП.КодыМаркировкиВыведеныИзОборота
			И Запись.ДальнейшееДействие1 = Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.НеТребуется Тогда
			
			докВыводИзОборота = Запись.Документ;
			СтатусВыводИзОборота = Перечисления.гф_СтатусыКМ_в_ШК.Выбыл;
			Для каждого стрШК Из докВыводИзОборота.ШтрихкодыУпаковок Цикл
				Если ЗначениеЗаполнено(стрШК["ШтрихкодУпаковки"]) 
					И стрШК["ШтрихкодУпаковки"]["ТипУпаковки"] = Перечисления.ТипыУпаковок.МаркированныйТовар Тогда
					обШК = стрШК["ШтрихкодУпаковки"].ПолучитьОбъект();
					Если обШК <> Неопределено Тогда
						обШК.гф_Статус = СтатусВыводИзОборота;
						обШК.Записать();
						ЗаписатьИсторияСтатусовКМ(Период, стрШК["ШтрихкодУпаковки"], СтатусВыводИзОборота, докВыводИзОборота);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		Если ТипЗнч(Запись.Документ) = Тип("ДокументСсылка.СписаниеКодовМаркировкиИСМП")
			И (Запись.Статус = Перечисления.СтатусыОбработкиСписанияКодовМаркировкиИСМП.КодыМаркировкиСписаны
			Или Запись.Статус = Перечисления.СтатусыОбработкиСписанияКодовМаркировкиИСМП.КодыМаркировкиСписаныЧастично)
			И Запись.ДальнейшееДействие1 = Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.НеТребуется Тогда
			
			докВыводИзОборота = Запись.Документ;
			СтатусВыводИзОборота = Перечисления.гф_СтатусыКМ_в_ШК.Выбыл;
			Для каждого стрШК Из докВыводИзОборота.ШтрихкодыУпаковок Цикл
				Если ЗначениеЗаполнено(стрШК["ШтрихкодУпаковки"]) 
					И стрШК["ШтрихкодУпаковки"]["ТипУпаковки"] = Перечисления.ТипыУпаковок.МаркированныйТовар Тогда
					обШК = стрШК["ШтрихкодУпаковки"].ПолучитьОбъект();
					Если обШК <> Неопределено Тогда
						обШК.гф_Статус = СтатусВыводИзОборота;
						обШК.Записать();
						ЗаписатьИсторияСтатусовКМ(Период, стрШК["ШтрихкодУпаковки"], СтатусВыводИзОборота, докВыводИзОборота);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		Если ТипЗнч(Запись.Документ) = Тип("ДокументСсылка.ОтгрузкаТоваровИСМП")
			И (Запись.Статус = Перечисления.СтатусыОбработкиОтгрузкиТоваровИСМП.Подтвержден
			Или Запись.Статус = Перечисления.СтатусыОбработкиОтгрузкиТоваровИСМП.ПодтвержденЧастично)
			И Запись.ДальнейшееДействие1 = Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.НеТребуется Тогда
			
			докОтгрузка = Запись.Документ;
			СтатусОтгружен = Перечисления.гф_СтатусыКМ_в_ШК.ОтгруженИСМП;
			Для каждого стрШК Из докОтгрузка.ШтрихкодыУпаковок Цикл
				Если ЗначениеЗаполнено(стрШК["ШтрихкодУпаковки"]) 
					И стрШК["ШтрихкодУпаковки"]["ТипУпаковки"] = Перечисления.ТипыУпаковок.МаркированныйТовар Тогда
					обШК = стрШК["ШтрихкодУпаковки"].ПолучитьОбъект();
					Если обШК <> Неопределено Тогда
						обШК.гф_Статус = СтатусОтгружен;
						обШК.Записать();
						ЗаписатьИсторияСтатусовКМ(Период, стрШК["ШтрихкодУпаковки"], СтатусОтгружен, докОтгрузка);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
	КонецЦикла; 
	
КонецПроцедуры // } #wortmann 

// vvv Галфинд \ Sakovich 20.07.2023
// см. ШтрихкодированиеИСМПСлужебный.ЭтоОперацияВводаВОборот()
Функция ЭтоОперацияВводаВОборот(Операция)
	
	Операции = Новый Массив;
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборот);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотМаркировкаОстатков);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотПолучениеПродукцииОтФизическихЛиц);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотПроизводствоВнеЕАЭС);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотПроизводствоРФ);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотПроизводствоРФПоДоговору);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотТрансграничнаяТорговля);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотПроизводствоРФПоДоговоруНаСторонеЗаказчика);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотИмпортСФТС);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотИмпортСФТСМех);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотКонтрактноеПроизводствоЕАЭС);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ИндивидуализацияКИЗ);

	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ОтчетОВерификацииНанесенныхКМ);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.УдалитьОтчетОПередачеКМНаПринтер);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.УдалитьОтчетОПередачеКМНаПроизводственнуюЛинию);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.УдалитьОтчетОПечатиКМ);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.УдалитьОтчетОПотереРаспечатанныхКМ);
	
	Возврат Операции.Найти(Операция) <> Неопределено;
	
КонецФункции // ^^^ Галфинд \ Sakovich 20.07.2023 

// ++ Галфинд СадомцевСА 04.08.2023 Исправил "ошибку" СонарКуба
Процедура гф_ДополнитьОчередьСообщений(РезультатОбмена, СвойстваПодписи);
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ *
	|ИЗ
	|	РегистрСведений.ОчередьСообщенийИСМП КАК ОчередьСообщенийИСМП
	|ГДЕ
	|	ОчередьСообщенийИСМП.Документ В(&МассивДокументы)";
 	МассивДокументы = Новый Массив;
	Для Каждого КлючИЗначение Из РезультатОбмена.ПараметрыОбмена.СообщенияКПодписанию Цикл
		Для Каждого Сообщение Из КлючИЗначение.Значение Цикл
			МассивДокументы.Добавить(Сообщение.Документ);
		КонецЦикла;
	КонецЦикла;
	Запрос.УстановитьПараметр("МассивДокументы", МассивДокументы);
	РезультатВсеДокументы = Запрос.Выполнить();
	Выборка = РезультатВсеДокументы.Выбрать();
	
	Для Каждого КлючИЗначение Из РезультатОбмена.ПараметрыОбмена.СообщенияКПодписанию Цикл
		Для Каждого Сообщение Из КлючИЗначение.Значение Цикл
			СтруктураПоиска = Новый Структура("Документ", Сообщение.Документ);
			Выборка.Сбросить();
			Если Выборка.НайтиСледующий(СтруктураПоиска) Тогда
				РеквизитыИсходящегоСообщения = Выборка.РеквизитыИсходящегоСообщения.Получить();
				ЗаполнитьЗначенияСвойств(РеквизитыИсходящегоСообщения, Сообщение);
				РеквизитыИсходящегоСообщения.Вставить("СвойстваПодписи", СвойстваПодписи);
				НаборЗаписей = РегистрыСведений.ОчередьСообщенийИСМП.СоздатьНаборЗаписей();
				СообщениеИдентификатор = Сообщение.Идентификатор;
				Если Не ЗначениеЗаполнено(СообщениеИдентификатор) Тогда
					СообщениеИдентификатор = Строка(Новый УникальныйИдентификатор);
				КонецЕсли;
				НаборЗаписей.Отбор.Сообщение.Установить(СообщениеИдентификатор);
				Запись = НаборЗаписей.Добавить();
				ЗаполнитьЗначенияСвойств(Запись, Сообщение);
				Запись.ДатаМодификацииУниверсальная = Дата(1,1,1);
				Запись.ДатаСоздания = Выборка.ДатаСоздания + 600;
				Запись.Сообщение = СообщениеИдентификатор;
				Запись.РеквизитыИсходящегоСообщения = Новый ХранилищеЗначения(РеквизитыИсходящегоСообщения);
				НаборЗаписей.Записать();
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
КонецПроцедуры
// -- Галфинд СадомцевСА 04.08.2023 Исправил "ошибку" СонарКуба
