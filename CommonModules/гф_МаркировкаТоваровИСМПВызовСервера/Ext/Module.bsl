﻿#Область ПрограммныйИнтерфейс

Функция гф_СоздатьМаркировкаТоваровИСМП(СтрокаТЗ, ДополнительныеПараметры = Неопределено) Экспорт
	
	СтруктураВозврата = Новый Структура("ОписаниеОшибки,"
	+ "МаркировкаТоваровИСМП,"
	+ "Организация,"
	+ "ЕстьОшибкиЗаполнения,"
	+ "ЕстьОшибки,"
	+ "Статус,"
	+ "ДальнейшееДействие,"
	+ "ЗаказКодовВозможен");
	
	Если Не ЗначениеЗаполнено(СтрокаТЗ.ДокументПоступления) Тогда
		СтруктураВозврата["ОписаниеОшибки"] = "Не заполнено основание для создания ""Маркировки товаров ИС МП""";
		Возврат СтруктураВозврата;
	КонецЕсли;
	
	Если ТипЗнч(СтрокаТЗ.ДокументПоступления) <> Тип("ДокументСсылка.ПриобретениеТоваровУслуг") Тогда
		СтруктураВозврата["ОписаниеОшибки"] = "Не корректно! Тип значения документа поступления:"
			+ ТипЗнч(СтрокаТЗ.ДокументПоступления);
		Возврат СтруктураВозврата;
	КонецЕсли;
	
	МаркировкаТоваровИСМП = Документы.МаркировкаТоваровИСМП.СоздатьДокумент();
	МаркировкаТоваровИСМП.Заполнить(СтрокаТЗ.ДокументПоступления);
	
	МаркировкаТоваровИСМП.Дата = ТекущаяДатаСеанса();
	МаркировкаТоваровИСМП.Операция = Перечисления.ВидыОперацийИСМП.ВводВОборотИмпортСФТС;
	МаркировкаТоваровИСМП.Комментарий = "Создан автоматически регл. заданием Маркировка товаров (ввод в оборот) "
		+ ТекущаяДатаСеанса();
	МаркировкаТоваровИСМП.РегистрационныйНомерДекларации = СокрЛП(СтрокаТЗ.ГТД.НомерДекларации);
	МаркировкаТоваровИСМП.ДатаДекларации = гф_ПолучитьДатуИзНомераДекларации(
		МаркировкаТоваровИСМП.РегистрационныйНомерДекларации);
	// ++ СадомцевСА 19.01.2024 Регл задание "Маркировка товаров (ввод в оборот)"
	// Реализовал заполнение полей Решение таможенного органа, Код в новом документе Маркировка товаров ИС МП
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eeb5ffa09cbb5f
	МаркировкаТоваровИСМП.ПринятоеРешение = Перечисления.ПринятыеРешенияИСМП.ВыпускТоваровРазрешен;
	ПозицияСлеша = СтрНайти(МаркировкаТоваровИСМП.РегистрационныйНомерДекларации, "/");
	Если ПозицияСлеша > 0 Тогда
		МаркировкаТоваровИСМП.КодТаможенногоОргана = Лев(МаркировкаТоваровИСМП.РегистрационныйНомерДекларации, ПозицияСлеша - 1);
	КонецЕсли;
	// -- СадомцевСА 19.01.2024
	
	// ++ СадомцевСА 19.07.2023
	// Реализовал новый алгорит заполнения нового документа Макрировка товаров ИС МП регл заданием
	// "Маркировка товаров (ввод в оборот)"
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee1f2d0fe515d4
	МаркировкаТоваровИСМП.Товары.Очистить();
	МаркировкаТоваровИСМП.ШтрихкодыУпаковок.Очистить();
	
	ЗаполнитьМаркировку(МаркировкаТоваровИСМП, СтрокаТЗ.ДокументПоступления);
	// -- СадомцевСА 19.07.2023
	
	гф_ПроверитьЗаполнениеЗаписать(МаркировкаТоваровИСМП, СтруктураВозврата);
	
	Возврат СтруктураВозврата;
	
КонецФункции

Процедура гф_ПодготовитьКПередачеИСМП(МассивВходящихДанных) Экспорт
	// Параметры:
	//  МассивВходящихДанных - массив ссылок Документ.МаркировкаТоваровИСМП
	
	Если Не ПолучитьФункциональнуюОпцию("ИспользоватьАвтоматическуюОтправкуПолучениеДанныхИСМП") Тогда
		Возврат;
	КонецЕсли;
	
	ВходящиеДанные = Новый Массив;
	Для Каждого Эл Из МассивВходящихДанных Цикл
		ПараметрыОбработкиДокументов = ИнтеграцияИСМПСлужебныйКлиентСервер.ПараметрыОбработкиДокументов();
		ПараметрыОбработкиДокументов.Ссылка = Эл;
		Организация = ОбщегоНазначенияУТВызовСервера.ЗначениеРеквизитаОбъекта(Эл, "Организация");
		ПараметрыОбработкиДокументов.Организация = Организация;
		ПараметрыОбработкиДокументов.ДальнейшееДействие = ПредопределенноеЗначение(
		"Перечисление.ДальнейшиеДействияПоВзаимодействиюИСМП.ПередайтеДанные");
		// ++ Галфинд СадомцевСА 04.07.2023 Дальнейшее действие для "подписания" документа зависит от Операции
		МенеджерОбъекта = ОбщегоНазначения.МенеджерОбъектаПоСсылке(Эл);
		СтруктураПараметров = Новый Структура("Операция, ОбъектРасчета", Эл.Операция, Эл);
		ПараметрыОбработкиДокументов.ДальнейшееДействие = МенеджерОбъекта.ДальнейшееДействиеПоУмолчанию(СтруктураПараметров);
		// --
		ВходящиеДанные.Добавить(ПараметрыОбработкиДокументов);
	КонецЦикла;
	РезультатОбмена = ИнтеграцияИСМПВызовСервера.ПодготовитьКПередаче(ВходящиеДанные);
	
	// Галфинд СадомцевСА 01.11.2023 Отменил доработки по письму от Вортмана
	//Если РезультатОбмена.Свойство("ПараметрыОбмена") Тогда
	//	СвойстваПодписи = гф_ЭлектроннаяПодписьВызовСервера.ПолучитьЗначениеКонстанты();
	//	Если ТипЗнч(СвойстваПодписи) <> Тип("Структура") Тогда
	//		Возврат;
	//	КонецЕсли;
	//	Если РезультатОбмена.ПараметрыОбмена.СообщенияКПодписанию = Неопределено Тогда
	//		Возврат;
	//	КонецЕсли;
	//	// Галфинд СадомцевСА 04.08.2023 Исправил "ошибку" СонарКуба
	//	гф_ДополнитьОчередьСообщений(РезультатОбмена, СвойстваПодписи);
	//КонецЕсли;

КонецПроцедуры

Функция гф_СоздатьМаркировкаТоваровИСМП_ОснованиеРТУ(СсылкаРТУ) Экспорт
	// ++ Галфинд СадомцевСА 04.07.2023 Реализовал создание документа Маркировка товаров ИСМП на основании РТУ
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee166b434dc8ce
	// Параметры:
	//  СсылкаРТУ - ссылка на Документ.РеализацияТоваровУслуг
	// Возвращаемое значение:
	//  СтруктураВозврата - тип Структура
	
	СтруктураВозврата = Новый Структура("ОписаниеОшибки,"
	+ "МаркировкаТоваровИСМП,"
	+ "Организация,"
	+ "ЕстьОшибкиЗаполнения,"
	+ "Статус,"
	+ "ДальнейшееДействие,"
	+ "ЗаказКодовВозможен");
	
	Если Не ЗначениеЗаполнено(СсылкаРТУ) Тогда
		СтруктураВозврата["ОписаниеОшибки"] = "Не заполнено основание для создания ""Маркировки товаров ИС МП""";
		Возврат СтруктураВозврата;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СсылкаРТУ.гф_МаркировкаТоваровИСМП) Тогда
		МаркировкаТоваровИСМП = СсылкаРТУ.гф_МаркировкаТоваровИСМП.ПолучитьОбъект();
		МаркировкаТоваровИСМП.Товары.Очистить();
		МаркировкаТоваровИСМП.ШтрихкодыУпаковок.Очистить();
	Иначе
		МаркировкаТоваровИСМП = Документы.МаркировкаТоваровИСМП.СоздатьДокумент();
	КонецЕсли;
	МаркировкаТоваровИСМП.Дата = ТекущаяДатаСеанса();
	МаркировкаТоваровИСМП.Операция = Перечисления.ВидыОперацийИСМП.Агрегация;
	МаркировкаТоваровИСМП.Организация = СсылкаРТУ.Организация;
	
	МаркировкаТоваровИСМП.ВариантЗаполненияДекларации = Перечисления.ВариантыЗаполненияДекларацииИСМП.КодыМаркировки;
	МаркировкаТоваровИСМП.ВариантФормированияАТКИСМП = Перечисления.ВариантыФормированияАТКИСМП.КодТНВЭД;
	
	МаркировкаТоваровИСМП.Ответственный = ПараметрыСеанса.ТекущийПользователь;
	МаркировкаТоваровИСМП.Комментарий = "#Создано автоматически для отгрузки в коробах " + ТекущаяДатаСеанса();
	Для Каждого СтрокаТЗ Из СсылкаРТУ.Товары Цикл
		нс = МаркировкаТоваровИСМП.Товары.Добавить();
		ЗаполнитьЗначенияСвойств(нс, СтрокаТЗ);
	КонецЦикла;
	// Галфинд СадомцевСА 07.08.2023 Исправил "ошибки" СонарКуба
	МаркировкаТоваровИСМПТоварыСвернуть(МаркировкаТоваровИСМП);
	
	// vvv Галфинд \ Sakovich 04.10.2023
	//в связи с изменением типового модуля ИнтеграцияИСМП в 2.5.12.111
	//ИнтеграцияИСМП.ЗаполнитьВидПродукцииПоТабличнойЧасти(МаркировкаТоваровИСМП);
	МаркировкаИСМПТовары = МаркировкаТоваровИСМП.Товары.Выгрузить();
	МассивВидовПродукции = ИнтеграцияИСМП.ВидыПродукцииПоТаблицеНоменклатуры(МаркировкаИСМПТовары);
	Если МассивВидовПродукции.ВГраница() > -1 Тогда
		МаркировкаТоваровИСМП.ВидПродукции = МассивВидовПродукции[0];
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 04.10.2023
	
	Для Каждого СтрокаТЗ Из СсылкаРТУ.ШтрихкодыУпаковок Цикл
		нс = МаркировкаТоваровИСМП.ШтрихкодыУпаковок.Добавить();
		ЗаполнитьЗначенияСвойств(нс, СтрокаТЗ);
	КонецЦикла;
	
	гф_ПроверитьЗаполнениеЗаписать(МаркировкаТоваровИСМП, СтруктураВозврата);
	
	Возврат СтруктураВозврата;
	
КонецФункции

#КонецОбласти

Процедура ЗаполнитьМаркировку(МаркировкаТоваровИСМП, ДокументПоступления)
	// СадомцевСА 19.07.2023
	// Реализовал новый алгорит заполнения нового документа Макрировка товаров ИС МП
	// регл заданием "Маркировка товаров (ввод в оборот)"
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee1f2d0fe515d4
	// Параметры:
	//  МаркировкаТоваровИСМП - документ объект МаркировкаТоваровИСМП
	//  ДокументПоступления - Ссылка на документ ПриобретениеТоваровУслуг
	
	// 1) Необходимо по каждому упаковочному листу в ПТиУ - смотреть Код упаковки в справочнике
	// "Штрихкоды товаров и упаковок"
	// - Искать мультитоварную упаковку (тип) оттуда забирать все коды маркировки.
	// Затем каждый код маркировки проверять в РС "Пересортица (удаляемые штрихкоды)"  - если есть,
	// смотреть регистратор - пересортица - искать эту пересортицу в РС "Пул кодов маркировки"
	// и подставлять за место старого.
	// Если в Пересортице несколько КД - брать по очереди.
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ПриобретениеТоваровУслуггф_ПродукцияВКоробах.Ссылка КАК Ссылка,
	|	ПриобретениеТоваровУслуггф_ПродукцияВКоробах.НомерСтроки КАК НомерСтроки,
	|	ПриобретениеТоваровУслуггф_ПродукцияВКоробах.ВариантКомплектации КАК ВариантКомплектации,
	|	ПриобретениеТоваровУслуггф_ПродукцияВКоробах.КоличествоКоробов КАК КоличествоКоробов,
	|	ПриобретениеТоваровУслуггф_ПродукцияВКоробах.IDКороба КАК IDКороба,
	|	ПриобретениеТоваровУслуггф_ПродукцияВКоробах.СтоимостьКороба КАК СтоимостьКороба,
	|	ПриобретениеТоваровУслуггф_ПродукцияВКоробах.IDКороба.гф_Агрегация КАК IDКоробагф_Агрегация,
	|	ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод КАК Штрихкод,
	|	ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод.ЗначениеШтрихкода КАК ЗначениеШтрихкода,
	|	ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод.Характеристика КАК Характеристика,
	|	УдаляемыеКМ.Пересортица КАК Пересортица
	|ИЗ
	|	Документ.ПриобретениеТоваровУслуг.гф_ПродукцияВКоробах КАК ПриобретениеТоваровУслуггф_ПродукцияВКоробах
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ШтрихкодыУпаковокТоваровВложенныеШтрихкоды
	|		ПО (ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Ссылка = ПриобретениеТоваровУслуггф_ПродукцияВКоробах.IDКороба.гф_Агрегация)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.гф_ПересортицаУдаляемыеШК КАК УдаляемыеКМ
	|		ПО ((ВЫРАЗИТЬ(УдаляемыеКМ.ШтрихкодУпаковки КАК Справочник.ШтрихкодыУпаковокТоваров)) = ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод)
	|ГДЕ
	|ПриобретениеТоваровУслуггф_ПродукцияВКоробах.Ссылка = &Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	Пересортица";
	Запрос.УстановитьПараметр("Ссылка", ДокументПоступления);
	Результат = Запрос.Выполнить();
	ТЗ = Результат.Выгрузить();
	ТЗПересортица = ТЗ.Скопировать();
	ТЗПересортица.Свернуть("Пересортица");
	// ++ Галфинд СадомцевСА 04.08.2023 Убрал "вызов" запроса из цикла
	МассивПересортица = ПодготовитьМассивПересортица(ТЗПересортица);
	Запрос.УстановитьПараметр("МассивПересортица", МассивПересортица);
	// -- Галфинд СадомцевСА 04.08.2023
	Запрос.Текст = "ВЫБРАТЬ
	|	ПулКодовМаркировкиСУЗ.КодМаркировки КАК КодМаркировки,
	|	ПулКодовМаркировкиСУЗ.ДокументОснование КАК Пересортица
	|ИЗ
	|	РегистрСведений.ПулКодовМаркировкиСУЗ КАК ПулКодовМаркировкиСУЗ
	|ГДЕ
	|ПулКодовМаркировкиСУЗ.ДокументОснование В(&МассивПересортица)";
	РезультатПересортица = Запрос.Выполнить();
	НовыеКМПересортица = РезультатПересортица.Выгрузить();
	
	// Для Каждого СтрокаПересортица Из ТЗПересортица Цикл
	Для Каждого Пересортица Из МассивПересортица Цикл
		// Если Не ЗначениеЗаполнено(СтрокаПересортица.Пересортица) Тогда
		//	Продолжить;
		// КонецЕсли;
		// Если ТипЗнч(СтрокаПересортица.Пересортица) <> Тип("ДокументСсылка.ПересортицаТоваров") Тогда
		//	Продолжить;
		// КонецЕсли;
			
		// СтруктураПоиска = Новый Структура("Пересортица", СтрокаПересортица.Пересортица);
		СтруктураПоиска = Новый Структура("Пересортица", Пересортица);
		НайденныеСтроки = ТЗ.НайтиСтроки(СтруктураПоиска);
		// Запрос.УстановитьПараметр("Пересортица", СтрокаПересортица.Пересортица);
		// Результат = Запрос.Выполнить();
		// НовыеКМ = Результат.Выгрузить();
		НовыеКМ = ПодготовитьНовыеКМ(НовыеКМПересортица, Пересортица);
			Индекс = 0;
		Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
			Если Индекс+1 > НовыеКМ.Количество() Тогда
				Прервать;
			КонецЕсли;
			НайденнаяСтрока.ЗначениеШтрихкода = НовыеКМ[Индекс].КодМаркировки;
			Индекс = Индекс + 1;
		КонецЦикла;
	КонецЦикла;
	
	// 2) Реализовал алгоритм кнопки "Загрузить из внешнего файла" документа Маркировка товаров ИС МП
	Штрихкоды = гф_КодыМаркировкиИзТабличногоДокумента(ТЗ.ВыгрузитьКолонку("ЗначениеШтрихкода"));
	
	ПараметрыСканирования = ШтрихкодированиеИС.ПараметрыСканирования(МаркировкаТоваровИСМП, Неопределено,
		МаркировкаТоваровИСМП.ВидПродукции); 
	
	гф_ПреобразоватьШтрихкодыТСДВBase64(Штрихкоды);

	СтруктураДокумента = ПодготовитьСтруктуруМаркировкаТоваровИСМП(МаркировкаТоваровИСМП);
	
	гф_ПодключитьОбработкуКодовМаркировки(СтруктураДокумента,,
			"ИдентификаторПроисхожденияВЕТИС,СрокГодности,GTIN,КоличествоПотребительскихУпаковок");

	Результат = ГрупповаяОбработкаШтрихкодовИС.ОбработатьПолученныеДанныеТСДВДокументе(СтруктураДокумента, Штрихкоды,
		ПараметрыСканирования);

	ПараметрыУказанияСерий = ИнтеграцияИС.ПараметрыУказанияСерийФормыОбъекта(МаркировкаТоваровИСМП,
		Документы.МаркировкаТоваровИСМП);
	
	гф_ОбработатьДобавленныеИзмененныеСтроки(Результат.ДобавленныеСтроки, Результат.ИзмененныеСтроки, СтруктураДокумента,
		ПараметрыУказанияСерий);
	
	МаркировкаТоваровИСМП.Товары.Загрузить(СтруктураДокумента.Товары);
	МаркировкаТоваровИСМП.ШтрихкодыУпаковок.Загрузить(СтруктураДокумента.ШтрихкодыУпаковок);
	
КонецПроцедуры

Процедура гф_ОбработатьДобавленныеИзмененныеСтроки(ДобавленныеСтроки, ИзмененныеСтроки, СтруктураДокумента,
	ПараметрыУказанияСерий)

	Для Каждого ДобавленнаяСтрока Из ДобавленныеСтроки Цикл
		ДобавленнаяСтрока.КоличествоУпаковок = 0;
		СобытияФормИСМППереопределяемый.ПриИзмененииНоменклатуры(
			СтруктураДокумента, ДобавленнаяСтрока, Неопределено, ПараметрыУказанияСерий);
		КонецЦикла;
		
КонецПроцедуры

Процедура гф_ПодключитьОбработкуКодовМаркировки(Форма, ЕстьТабличнаяЧастьШтрихкодыУпаковок=Истина,
	ДополнительныеКлючиШтрихкодовУпаковок = "")
	
	КэшМаркируемойПродукции = ШтрихкодированиеИС.ИнициализацияКэшаМаркируемойПродукции();
	// Форма.КэшМаркируемойПродукции = ПоместитьВоВременноеХранилище(
	//	ШтрихкодированиеИС.ИнициализацияКэшаМаркируемойПродукции(), Форма.УникальныйИдентификатор);
	Форма.КэшМаркируемойПродукции = ПоместитьВоВременноеХранилище(
		КэшМаркируемойПродукции, Форма.УникальныйИдентификатор);

	Если ЕстьТабличнаяЧастьШтрихкодыУпаковок Тогда
		ДобавляемыеРеквизиты = Новый Массив;
		ПроверкаИПодборПродукцииИС.ДобавитьТаблицуШтрихкодовУпаковок(Форма, Новый Соответствие, ДобавляемыеРеквизиты,
			ДополнительныеКлючиШтрихкодовУпаковок);
		ТЗ = Новый ТаблицаЗначений;
		Для Каждого Реквизит Из ДобавляемыеРеквизиты Цикл
			Если Реквизит.Имя = "ДанныеШтрихкодовУпаковокГосИС" Тогда
				Продолжить;
			КонецЕсли;
			ТЗ.Колонки.Добавить(Реквизит.Имя, Реквизит.ТипЗначения);
		КонецЦикла;
		Форма.Вставить("ДанныеШтрихкодовУпаковокГосИС", ТЗ);
	КонецЕсли;

	ШтрихкодированиеИС.ОбновитьКэшМаркируемойПродукции(Форма);
	
КонецПроцедуры

Функция ПодготовитьСтруктуруМаркировкаТоваровИСМП(МаркировкаТоваровИСМП)
	СтруктураРеквизитов = Новый Структура;
	Для Каждого Реквизит Из Метаданные.Документы.МаркировкаТоваровИСМП.Реквизиты Цикл
		СтруктураРеквизитов.Вставить(Реквизит.Имя);
	КонецЦикла;
	ЗаполнитьЗначенияСвойств(СтруктураРеквизитов, МаркировкаТоваровИСМП);
	
	ТЗ = Новый ТаблицаЗначений;
	Для Каждого Реквизит Из Метаданные.Документы.МаркировкаТоваровИСМП.ТабличныеЧасти.Товары.Реквизиты Цикл
		ТЗ.Колонки.Добавить(Реквизит.Имя, Реквизит.Тип);
	КонецЦикла;
	ТЗ.Колонки.Добавить("ТипНоменклатуры", Новый ОписаниеТипов("ПеречислениеСсылка.ТипыНоменклатуры"));
	ТЗ.Колонки.Добавить("ХарактеристикиИспользуются", Новый ОписаниеТипов("Булево"));
	СтруктураРеквизитов.Вставить("Товары", ТЗ);

	ТЗ = Новый ТаблицаЗначений;
	Для Каждого Реквизит Из Метаданные.Документы.МаркировкаТоваровИСМП.ТабличныеЧасти.ШтрихкодыУпаковок.Реквизиты Цикл
		ТЗ.Колонки.Добавить(Реквизит.Имя, Реквизит.Тип);
	КонецЦикла;
	СтруктураРеквизитов.Вставить("ШтрихкодыУпаковок", ТЗ);

	СтруктураРеквизитов.Вставить("УникальныйИдентификатор", Новый УникальныйИдентификатор);
	СтруктураРеквизитов.Вставить("ИмяФормы", "Документ.МаркировкаТоваровИСМП.Форма.ФормаДокумента");
	СтруктураРеквизитов.Вставить("КэшМаркируемойПродукции");
	
	СтрОбъект = ПодготовитьОбъект(СтруктураРеквизитов);
	
	СтруктураРеквизитов.Вставить("Объект", СтрОбъект);
	
	Возврат СтруктураРеквизитов;
КонецФункции

Функция ПодготовитьОбъект(СтруктураРеквизитов)
	СтрОбъект = Новый Структура;
	
	Для Каждого Элемент Из СтруктураРеквизитов Цикл
		СтрОбъект.Вставить(Элемент.Ключ, Элемент.Значение);
	КонецЦикла;	
		
	Возврат СтрОбъект;
КонецФункции

Процедура гф_ПреобразоватьШтрихкодыТСДВBase64(ШтрихкодыТСД)
	
	Для Каждого ЭлементМассива Из ШтрихкодыТСД Цикл
		Если ЭлементМассива.Свойство("ШтрихкодыПреобразованы") Тогда
			Продолжить;
		КонецЕсли;
		
		ЕстьСвойствоФорматBase64 = Ложь;
		Если ЭлементМассива.Свойство("ФорматBase64") Тогда
			ФорматBase64 = ЭлементМассива.ФорматBase64;
			ЕстьСвойствоФорматBase64 = Истина;
		Иначе
			ФорматBase64 = Ложь;
		КонецЕсли;
		
		Если Не ФорматBase64 Тогда
			Если ЗначениеЗаполнено(ЭлементМассива.Штрихкод) Тогда
				ЭлементМассива.Штрихкод = ШтрихкодированиеИСКлиентСервер.ШтрихкодВBase64(ЭлементМассива.Штрихкод);
				Если ЕстьСвойствоФорматBase64 Тогда
					ЭлементМассива.ФорматBase64 = Истина;
				Иначе
					ЭлементМассива.Вставить("ФорматBase64", Истина);
				КонецЕсли;
			КонецЕсли;
			Если ЭлементМассива.Свойство("ШтрихкодУпаковки") И ЗначениеЗаполнено(ЭлементМассива.ШтрихкодУпаковки) Тогда
				ЭлементМассива.ШтрихкодУпаковки = ШтрихкодированиеИСКлиентСервер.ШтрихкодВBase64(ЭлементМассива.ШтрихкодУпаковки);
				Если ЕстьСвойствоФорматBase64 Тогда
					ЭлементМассива.ФорматBase64 = Истина;
				Иначе
					ЭлементМассива.Вставить("ФорматBase64", Истина);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		ЭлементМассива.Вставить("ШтрихкодыПреобразованы");
	КонецЦикла;
	
КонецПроцедуры

Функция гф_КодыМаркировкиИзТабличногоДокумента(МассивШтрихкоды)
	
	Результат = Новый Массив;
	
	Для Каждого Штрихкод Из МассивШтрихкоды Цикл
		Если ЗначениеЗаполнено(Штрихкод) Тогда
			
			СодержитНедопустимыеСимволы = Ложь;
			
			Если РазборКодаМаркировкиИССлужебныйКлиентСервер.НайденНедопустимыйСимволXML(Штрихкод) Тогда
				СодержитНедопустимыеСимволы = Истина;
			КонецЕсли;
			
			Если СодержитНедопустимыеСимволы Тогда
				Штрихкод = ШтрихкодированиеИСКлиентСервер.ШтрихкодВBase64(Штрихкод);
			КонецЕсли;
			
			ПоляСтроки = Новый Структура;
			ПоляСтроки.Вставить("Штрихкод",                          СокрЛП(Штрихкод));
			ПоляСтроки.Вставить("Количество",                        1);
			ПоляСтроки.Вставить("ШтрихкодМаркиАлкогольнойПродукции", "");
			ПоляСтроки.Вставить("ШтрихкодУпаковки",                  "");
			ПоляСтроки.Вставить("ФорматBase64",                      Ложь);
			
			Результат.Добавить(ПоляСтроки);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция гф_ПолучитьДатуИзНомераДекларации(НомерДекларации)
	_День = Сред(НомерДекларации, 10, 2);
	Если ЗначениеЗаполнено(_День) Тогда
		День = Число(_День);
	Иначе
		День = 1;
	КонецЕсли;
	_Месяц = Сред(НомерДекларации, 12, 2);
	Если ЗначениеЗаполнено(_Месяц) Тогда
		Месяц = Число(_Месяц);
	Иначе
		Месяц = 1;
	КонецЕсли;
	_Год = Сред(НомерДекларации, 14, 2);
	Если ЗначениеЗаполнено(_Год) Тогда
		Год = Число("20"+_Год);
	Иначе
		Год = 1;
	КонецЕсли;
	Возврат Дата(Год, Месяц, День);
КонецФункции

Функция ПодготовитьМассивПересортица(ТЗПересортица)
	// ++ Галфинд СадомцевСА 04.08.2023 Убрал "вызов" запроса из цикла
	// Параметры:
	//  ТЗПересортица - таблица значений
	// Возвращаемое значение:
	// 	МассивПересортица - массив
	МассивПересортица = Новый Массив;
	Для Каждого СтрокаПересортица Из ТЗПересортица Цикл
		Если Не ЗначениеЗаполнено(СтрокаПересортица.Пересортица) Тогда
			Продолжить;
		КонецЕсли;
		Если ТипЗнч(СтрокаПересортица.Пересортица) <> Тип("ДокументСсылка.ПересортицаТоваров") Тогда
			Продолжить;
		КонецЕсли;
		МассивПересортица.Добавить(СтрокаПересортица.Пересортица);
	КонецЦикла;
    Возврат МассивПересортица;
КонецФункции

Функция ПодготовитьНовыеКМ(НовыеКМПересортица, Пересортица)
	НовыеКМ = НовыеКМПересортица.СкопироватьКолонки("КодМаркировки");
	СтруктураПоиска = Новый Структура("Пересортица", Пересортица);
	НайденныеСтроки = НовыеКМПересортица.НайтиСтроки(СтруктураПоиска);
	Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
		нс = НовыеКМ.Добавить();
		ЗаполнитьЗначенияСвойств(нс, НайденнаяСтрока);
	КонецЦикла;
	Возврат НовыеКМ;
КонецФункции

Процедура гф_ДополнитьОчередьСообщений(РезультатОбмена, СвойстваПодписи)
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

Процедура гф_ПроверитьЗаполнениеЗаписать(МаркировкаТоваровИСМП, СтруктураВозврата)
	// 1-я проверка
	РезультатПроверки = ИнтеграцияИСМПСлужебный.гф_ПроверитьЗаполнениеШтрихкодовУпаковок(МаркировкаТоваровИСМП);
	Если РезультатПроверки.ДанныеСоответствуют Тогда
		РежимЗаписи = РежимЗаписиДокумента.Проведение;
		СтруктураВозврата["ЕстьОшибкиЗаполнения"] = Ложь;
	Иначе
		// Галфинд СадомцевСА 20.06.2023 Реализовал "удаление" строки тч при "нулевом" количестве
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee09e0e1b3a4bf
		МассивУдалитьСтроки = Новый Массив;
		Для Каждого СтрокаСРасхожнением Из РезультатПроверки.СтрокиСРасхождением Цикл
			Если СтрокаСРасхожнением.НомерСтроки > МаркировкаТоваровИСМП.Товары.Количество() Тогда
				Продолжить;
			КонецЕсли;
			СтрокаТЧ = МаркировкаТоваровИСМП.Товары[СтрокаСРасхожнением.НомерСтроки-1];
			СтрокаТЧ[СтрокаСРасхожнением.Поле] = СтрокаСРасхожнением.Указано;
			СтрокаТЧ["Количество"] = СтрокаТЧ[СтрокаСРасхожнением.Поле];
			СтрокаТЧ.Сумма = СтрокаТЧ.Цена * СтрокаТЧ["Количество"];
			СтрокаТЧ.СуммаСНДС = СтрокаТЧ.Цена * СтрокаТЧ["Количество"];
			Если Не ЗначениеЗаполнено(СтрокаТЧ["Количество"]) Тогда
				МассивУдалитьСтроки.Добавить(СтрокаТЧ);
			КонецЕсли;
		КонецЦикла;
		// Галфинд СадомцевСА 07.08.2023 Исправил "ошибки" СонарКуба
		УдалитьСтрокиТЧ(МаркировкаТоваровИСМП, МассивУдалитьСтроки);
		
		// 2-я проверка
		РезультатПроверки = ИнтеграцияИСМПСлужебный.гф_ПроверитьЗаполнениеШтрихкодовУпаковок(МаркировкаТоваровИСМП);
		Если РезультатПроверки.ДанныеСоответствуют Тогда
			РежимЗаписи = РежимЗаписиДокумента.Проведение;
			СтруктураВозврата["ЕстьОшибкиЗаполнения"] = Ложь;
		Иначе
			РежимЗаписи = РежимЗаписиДокумента.Запись;
			СтруктураВозврата["ЕстьОшибкиЗаполнения"] = Истина;
			МаркировкаТоваровИСМП.Комментарий = МаркировкаТоваровИСМП.Комментарий + Символы.ПС +
				"Есть ошибки при проверке документа (НЕ проведен)!";
		КонецЕсли;
	КонецЕсли;
	// Галфинд СадомцевСА 07.08.2023 Исправил "ошибки" СонарКуба
	// ++ Галфинд СадомцевСА 19.01.2024 Сначала записываем документ Маркировка товаров ИС МП - потом проводим
	Если СтруктураВозврата.Свойство("ЕстьОшибки") Тогда
		СтруктураВозврата["ЕстьОшибки"] = Ложь;
	Иначе
		СтруктураВозврата.Вставить("ЕстьОшибки", Ложь);
	КонецЕсли;
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		ЗаписатьВПопытке(МаркировкаТоваровИСМП, РежимЗаписиДокумента.Запись, СтруктураВозврата);
		Если СтруктураВозврата["ЕстьОшибки"] = Ложь Тогда
			ЗаписатьВПопытке(МаркировкаТоваровИСМП, РежимЗаписи, СтруктураВозврата);
		КонецЕсли;
	Иначе
		ЗаписатьВПопытке(МаркировкаТоваровИСМП, РежимЗаписи, СтруктураВозврата);
	КонецЕсли;
	// -- Галфинд СадомцевСА 19.01.2024
КонецПроцедуры

Процедура МаркировкаТоваровИСМПТоварыСвернуть(МаркировкаТоваровИСМП)
	// ++ Галфинд СадомцевСА 07.08.2023 Исправил "ошибки" СонарКуба
	КолонкиГруппировки = "";
	КолонкиСуммирования = "";
	Для Каждого Реквизит Из Метаданные.Документы.МаркировкаТоваровИСМП.ТабличныеЧасти.Товары.Реквизиты Цикл
		Если Реквизит.Тип.СодержитТип(Тип("Число")) И Реквизит.Имя <> "Цена" Тогда
			Если КолонкиСуммирования <> "" Тогда
				КолонкиСуммирования = КолонкиСуммирования + ",";
			КонецЕсли;
			КолонкиСуммирования = КолонкиСуммирования + Реквизит.Имя;
		Иначе
			Если КолонкиГруппировки <> "" Тогда
				КолонкиГруппировки = КолонкиГруппировки + ",";
			КонецЕсли;
			КолонкиГруппировки = КолонкиГруппировки + Реквизит.Имя;
		КонецЕсли;
	КонецЦикла;
	МаркировкаТоваровИСМП.Товары.Свернуть(КолонкиГруппировки, КолонкиСуммирования);
КонецПроцедуры

Процедура ЗаписатьВПопытке(МаркировкаТоваровИСМП, РежимЗаписи, СтруктураВозврата)
	Попытка
		МаркировкаТоваровИСМП.Записать(РежимЗаписи);
		Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
			СтруктураВозврата["МаркировкаТоваровИСМП"] = МаркировкаТоваровИСМП.Ссылка;
		КонецЕсли;
	Исключение
		СтруктураВозврата["ОписаниеОшибки"] = "Ошибка при записи документа:" + ОписаниеОшибки();
		// ++ Галфинд СадомцевСА 19.01.2024 Добавил сообщение об ошибке в журнал регистрации
		СтруктураВозврата["ЕстьОшибки"] = Истина;
		Если МаркировкаТоваровИСМП.ДополнительныеСвойства.Свойство("НеОпубликованыТовары") Тогда
			СтруктураВозврата.Вставить("НеОпубликованыТовары",
				МаркировкаТоваровИСМП.ДополнительныеСвойства["НеОпубликованыТовары"]);
		КонецЕсли;
		// -- Галфинд СадомцевСА 19.01.2024
	КонецПопытки;
КонецПроцедуры

Процедура УдалитьСтрокиТЧ(МаркировкаТоваровИСМП, МассивУдалитьСтроки)
	Для Каждого УдалитьСтроку Из МассивУдалитьСтроки Цикл
		МаркировкаТоваровИСМП.Товары.Удалить(УдалитьСтроку);
	КонецЦикла;
КонецПроцедуры
