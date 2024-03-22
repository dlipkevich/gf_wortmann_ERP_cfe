﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий 

&После("ОбработкаПроведения")
Процедура гф_ОбработкаПроведения(Отказ, РежимПроведения)
	// ++ Галфинд_Домнышева 2023/04/10 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8131bcee7bda45d711edd201ed470fa8
	Если ЗначениеЗаполнено(ЗаявкаНаВозвратТоваровОтКлиента) Тогда
		//ЗапросТекст = гф_ПолучитьТекст();
		//ЗапросТоваровКПоступлению = ТекстыЗапроса.НайтиПоЗначению(ЗапросТекст);
		// РН ЗаказыКлиентов
	ДокументСсылка = ЭтотОбъект.Ссылка;
	Документ = ДокументСсылка.ПолучитьОбъект();
	
	НаборЗаписей = Документ.Движения.ТоварыКПоступлению;
	НаборЗаписей.Прочитать();
	МассивЗаписейНаУдаление = Новый Массив;

	Для Каждого Запись Из НаборЗаписей Цикл
		
		Если Запись.ДокументПоступления = Ссылка Тогда
			МассивЗаписейНаУдаление.Добавить(Запись);
		КонецЕсли;
		
	КонецЦикла;
	
	Для каждого ЗаписьКУдалению Из МассивЗаписейНаУдаление Цикл
	НаборЗаписей.Удалить(ЗаписьКУдалению);
    КонецЦикла;
	
	НаборЗаписей.Записать(Истина);
	
	// ++ Галфинд_ДомнышеваКР_01_03_2024
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eea55516d71e36
	ДвиженияСебестоимостьТоварыОрганизации(Документ);
	// -- Галфинд_ДомнышеваКР_01_03_2024
	
	КонецЕсли;
     // -- Галфинд_Домнышева 2023/04/10
КонецПроцедуры

&После("ПриЗаписи")
Процедура гф_ПриЗаписи(Отказ)
	// ++ Галфинд_Домнышева 2023/04/10 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8131bcee7bda45d711edd201ed470fa8
	РежимЗаписи = ДополнительныеСвойства.ПроведениеДокументов.СвойстваДокумента.РежимЗаписи;

	Если РежимЗаписи = РежимЗаписиДокумента.ОтменаПроведения Тогда
		Возврат;
	КонецЕсли; 
	
	Если ЗначениеЗаполнено(ЗаявкаНаВозвратТоваровОтКлиента)
		// Изменено Галфинд_Домнышева_26_06_2023 В связи с добавлением новых статусов в Заявку на возврат, 
		// документ Возврат создается когда заявка в статусе гф_КМПроверены или гф_ТоварПеремаркирован 
		// (добавлено Домнышева_24_11_2023)
		И (ЗаявкаНаВозвратТоваровОтКлиента.Статус = Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.гф_КМПроверены
		ИЛИ 
		ЗаявкаНаВозвратТоваровОтКлиента.Статус = Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.гф_ТоварПеремаркирован) 
		Тогда 
		СчетФактура = ПолучитьСчетФактуруПоСвязаннымДокумента(ДокументРеализации);	
		Если СчетФактура <> Неопределено Тогда
			СчетФактураОбъект = СчетФактура.ПолучитьОбъект();
			СчетФактураОбъект.ДокументОснование = Ссылка;
			СчетФактураОбъект.Перевыставленный = Ложь;
			СчетФактураОбъект.ДокументыОснования[0].ДокументОснование = Ссылка;
			СчетФактураОбъект.ОбменДанными.Загрузка = Истина;
			СчетФактураОбъект.Записать();
			ПараметрыРегистрации = Документы.ВозвратТоваровОтКлиента.ПараметрыРегистрацииСчетовФактурПолученных(ЭтотОбъект);
			ПараметрыРегистрации.Дата = СчетФактура.Дата; // Галфинд_ДомнышеваКР_22_03_2024
			//РежимЗаписи = ДополнительныеСвойства.ПроведениеДокументов.СвойстваДокумента.РежимЗаписи;
			УчетНДСУП.АктуализироватьСчетаФактурыПолученныеПередЗаписью(ПараметрыРегистрации, РежимЗаписи, 
			ПометкаУдаления, Проведен);
		КонецЕсли;
	КонецЕсли;
    // -- Галфинд_Домнышева 2023/04/10

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
// #wortmann { 
// Получение Счет-фактуры по ДокументРеализации 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8131bcee7bda45d711edd201ed470fa8
// Галфинд_Домнышева 2023/04/10
Функция ПолучитьСчетФактуруПоСвязаннымДокумента(ДокументРеализации)
	
	// текст запроса изменен
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee8a9b9679e068
	// Галфинд_домнышеваКР_24_11_2023
	// В связи с отсутствие в ШКУп возвращаемой позиции, изменен запрос _Галфинд_Домнышева_09_02_2024
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТоварыПоВозврату.Номенклатура КАК Номенклатура,
		|	ТоварыПоВозврату.Характеристика КАК Характеристика
		|ПОМЕСТИТЬ ТоварыВозврата
		|ИЗ
		|	&ТоварыПоВозврату КАК ТоварыПоВозврату
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	КорректировкаРеализацииРасхождения.Ссылка КАК Ссылка
		|ПОМЕСТИТЬ ВременнаяТаблица
		|ИЗ
		|	Документ.КорректировкаРеализации.Расхождения КАК КорректировкаРеализацииРасхождения
		|ГДЕ
		|	КорректировкаРеализацииРасхождения.Ссылка.ДокументОснование = &ДокументРеализации
		|	И (КорректировкаРеализацииРасхождения.Номенклатура, КорректировкаРеализацииРасхождения.Характеристика) В
		|			(ВЫБРАТЬ
		|				ТоварыВозврата.Номенклатура,
		|				ТоварыВозврата.Характеристика
		|			ИЗ
		|				ТоварыВозврата КАК ТоварыВозврата)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	СчетФактураВыданный.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.СчетФактураВыданный КАК СчетФактураВыданный,
		|	ВременнаяТаблица КАК ВременнаяТаблица
		|ГДЕ
		|	СчетФактураВыданный.ДокументОснование В (ВременнаяТаблица.Ссылка)
		|	И СчетФактураВыданный.ПометкаУдаления = ЛОЖЬ";
	
	ТоварыПоВозврату = ЭтотОбъект.Товары.Выгрузить();
	ТоварыПоВозврату.Свернуть("Номенклатура, Характеристика"); 
	
	Запрос.УстановитьПараметр("ТоварыПоВозврату", ТоварыПоВозврату);

	Запрос.УстановитьПараметр("ДокументРеализации", ДокументРеализации);
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		Выборка.Следующий();
		Возврат Выборка.Ссылка;
	КонецЕсли;

КонецФункции// } #wortmann

// #wortmann { 
// Изменение КорАналитикиУчетаНоменклатуры в РН ТоварыОрганизаций и СебестоимостьТоваров 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eea55516d71e36
// Галфинд_Домнышева 2024/03/01
Процедура ДвиженияСебестоимостьТоварыОрганизации(Документ)
	
	ТоварыКЗаполнению = ЗаполнитьКлючиАналитикиУчетаНоменклатуры();
	СтруктураПоиска = Новый Структура;
	СтруктураПоиска.Вставить("Номенклатура");
	СтруктураПоиска.Вставить("Характеристика");
	
	НаборТоварыОрганизации = Документ.Движения.ТоварыОрганизаций;
	НаборТоварыОрганизации.Прочитать();

	Для Каждого Запись Из НаборТоварыОрганизации Цикл
		
		СтруктураПоиска.Номенклатура = Запись.Номенклатура;
		СтруктураПоиска.Характеристика = Запись.Характеристика;
		Строки = ТоварыКЗаполнению.НайтиСтроки(СтруктураПоиска);
		Если Строки.Количество() > 0 Тогда 
			Запись.КорАналитикаУчетаНоменклатуры = Строки[0].АналитикаУчетаНоменклатуры;
		КонецЕсли;
	
	КонецЦикла;
	
	НаборТоварыОрганизации.Записать(Истина); 
	
	НаборСебестоимость = Документ.Движения.СебестоимостьТоваров;
	НаборСебестоимость.Прочитать();

	Для Каждого Запись Из НаборСебестоимость Цикл
		
		СтруктураПоиска.Номенклатура = Запись.АналитикаУчетаНоменклатуры.Номенклатура;
		СтруктураПоиска.Характеристика = Запись.АналитикаУчетаНоменклатуры.Характеристика;
		Строки = ТоварыКЗаполнению.НайтиСтроки(СтруктураПоиска);
		Если Строки.Количество() > 0 Тогда 
			Запись.КорАналитикаУчетаНоменклатуры = Строки[0].АналитикаУчетаНоменклатуры;
		КонецЕсли;
		
	КонецЦикла;
	
	НаборСебестоимость.Записать(Истина);

КонецПроцедуры// } #wortmann

// #wortmann { 
// Вызов Подбора или создания АналитикиУчетаНоменклатуры по Назначению из реализации 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eea55516d71e36
// Галфинд_Домнышева 2024/03/01
Функция ЗаполнитьКлючиАналитикиУчетаНоменклатуры()
	
	МестаУчета = РегистрыСведений.АналитикаУчетаНоменклатуры.МестаУчета
								(ХозяйственнаяОперация,
								Склад,
								Неопределено,
								Неопределено);
	
	ИменаПолей = РегистрыСведений.АналитикаУчетаНоменклатуры.ИменаПолейКоллекцииПоУмолчанию();
	ИменаПолей.Вставить("Назначение", "Назначение");
	ИменаПолей.Вставить("СтатусУказанияСерий", Неопределено);
	
	ТоварыКЗаполнению = ПолучитьТовары();
	РегистрыСведений.АналитикаУчетаНоменклатуры.ЗаполнитьВКоллекции(ТоварыКЗаполнению, МестаУчета, ИменаПолей);
	
	Возврат ТоварыКЗаполнению;
	
КонецФункции// } #wortmann

// #wortmann { 
// Получение ТЗ с Товарами по Возврату для подбора АналитикиУчетаНоменклатуры по Назначению из реализации 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eea55516d71e36
// Галфинд_Домнышева 2024/03/01
Функция ПолучитьТовары() 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВозвратТоваровОтКлиентаТовары.НомерСтроки КАК НомерСтроки,
		|	ВозвратТоваровОтКлиентаТовары.Номенклатура КАК Номенклатура,
		|	ВозвратТоваровОтКлиентаТовары.Характеристика КАК Характеристика,
		|	ВозвратТоваровОтКлиентаТовары.Упаковка КАК Упаковка,
		|	ВозвратТоваровОтКлиентаТовары.КоличествоУпаковок КАК КоличествоУпаковок,
		|	ВозвратТоваровОтКлиентаТовары.Количество КАК Количество,
		|	ВозвратТоваровОтКлиентаТовары.Цена КАК Цена,
		|	ВозвратТоваровОтКлиентаТовары.Сумма КАК Сумма,
		|	ВозвратТоваровОтКлиентаТовары.СтавкаНДС КАК СтавкаНДС,
		|	ВозвратТоваровОтКлиентаТовары.Серия КАК Серия,
		|	ВозвратТоваровОтКлиентаТовары.ДокументРеализации КАК Регистратор,
		|	ВозвратТоваровОтКлиентаТовары.СтатусУказанияСерий КАК СтатусУказанияСерий
		|ПОМЕСТИТЬ ТоварыВозврат
		|ИЗ
		|	Документ.ВозвратТоваровОтКлиента.Товары КАК ВозвратТоваровОтКлиентаТовары
		|ГДЕ
		|	ВозвратТоваровОтКлиентаТовары.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТоварыОрганизаций.Регистратор КАК Регистратор,
		|	ТоварыОрганизаций.Номенклатура КАК Номенклатура,
		|	ТоварыОрганизаций.Характеристика КАК Характеристика,
		|	ТоварыОрганизаций.АналитикаУчетаНоменклатуры.Назначение КАК АналитикаУчетаНоменклатурыНазначение
		|ПОМЕСТИТЬ Назначения
		|ИЗ
		|	РегистрНакопления.ТоварыОрганизаций КАК ТоварыОрганизаций
		|ГДЕ
		|	(ТоварыОрганизаций.Регистратор, ТоварыОрганизаций.Номенклатура, ТоварыОрганизаций.Характеристика) В
		|			(ВЫБРАТЬ
		|				Т.Регистратор,
		|				Т.Номенклатура,
		|				Т.Характеристика
		|			ИЗ
		|				ТоварыВозврат КАК Т)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТоварыВозврат.НомерСтроки КАК НомерСтроки,
		|	ТоварыВозврат.Номенклатура КАК Номенклатура,
		|	ТоварыВозврат.Характеристика КАК Характеристика,
		|	ТоварыВозврат.Упаковка КАК Упаковка,
		|	ТоварыВозврат.КоличествоУпаковок КАК КоличествоУпаковок,
		|	ТоварыВозврат.Количество КАК Количество,
		|	ТоварыВозврат.Цена КАК Цена,
		|	ТоварыВозврат.Сумма КАК Сумма,
		|	ТоварыВозврат.СтавкаНДС КАК СтавкаНДС,
		|	ТоварыВозврат.Серия КАК Серия,
		|	ТоварыВозврат.Регистратор КАК ДокументРеализации,
		|	ТоварыВозврат.СтатусУказанияСерий КАК СтатусУказанияСерий,
		|	Назначения.АналитикаУчетаНоменклатурыНазначение КАК Назначение,
		|   Значение(Справочник.КлючиАналитикиУчетаНоменклатуры.Пустаяссылка) КАК АналитикаУчетаНоменклатуры
		|ИЗ
		|	ТоварыВозврат КАК ТоварыВозврат
		|		ЛЕВОЕ СОЕДИНЕНИЕ Назначения КАК Назначения
		|		ПО ТоварыВозврат.Номенклатура = Назначения.Номенклатура
		|			И ТоварыВозврат.Характеристика = Назначения.Характеристика
		|			И ТоварыВозврат.Регистратор = Назначения.Регистратор";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса.Выгрузить();
	
КонецФункции// } #wortmann

#КонецОбласти

#КонецЕсли
