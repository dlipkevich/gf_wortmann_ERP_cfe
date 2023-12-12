﻿
&Вместо("ВыставитьСчетаНаОплату")
Процедура гф_ВыставитьСчетаНаОплату() Экспорт
	
	Попытка 
		ЗаписьЖурналаРегистрации("РегламентноеВыставлениеСчетов.СтартОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ВыставлениеСчетов);
		ОбработкаЗапуска = Обработки.гф_ВыставлениеСчетов.Создать();
		ОбработкаЗапуска.ВыставитьСчетаНаПоставку(); 
		ЗаписьЖурналаРегистрации("РегламентноеВыставлениеСчетов.ЗавершениеОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ВыставлениеСчетов);
	Исключение
		ОписаниеОшибки = ОписаниеОшибки();  
		СтрокаСообщений = "Ошибка при запуске обработки: " + ОписаниеОшибки;
		ЗаписьЖурналаРегистрации("РегламентноеВыставлениеСчетов.ОшибкаПриЗапуске", УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Обработки.гф_ВыставлениеСчетов,,СтрокаСообщений);
	КонецПопытки;
	
	ПродолжитьВызов();
	
КонецПроцедуры

&Вместо("Почта_России_ЗапроситьДанныеТрекинга")
Процедура гф_Почта_России_ЗапроситьДанныеТрекинга() Экспорт
	
	гф_ПочтаРоссии.ОбновитьДанныеОтслеживаемыхОтправлений();
	
КонецПроцедуры

// #wortmann {
// #2.1 Интеграция с маркетплейсами
// Метод регламентного задания Загрузка продаж Wildberries
// Галфинд (Уфимцев) Перминов 2022/11/15
&Вместо("ЗапроситьПродажиWildberries")
Процедура гф_ЗапроситьПродажиWildberries()
	
	Попытка
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаПродажWildberries.СтартОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаПродажWildberries);
		ОбработкаЗапуска = Обработки.гф_ЗагрузкаПродажWildberries.Создать();
		ОбработкаЗапуска.ВыполнитьКоманду("ЗагрузкаПродажWildberriesAPI");
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаПродажWildberries.ЗавершениеОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаПродажWildberries);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаПродажWildberries.ОшибкаПриЗапуске", УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Обработки.гф_ЗагрузкаПродажWildberries,,СтрокаСообщения);
	КонецПопытки;
	
	ПродолжитьВызов();
	
КонецПроцедуры // } #wortmann 

// #wortmann {
// #2.2 Интеграция с маркетплейсами
// Метод регламентного задания Загрузка продаж Cactus
// Галфинд (Уфимцев) Перминов 2022/11/15
&Вместо("ЗапроситьПродажиCactus")
Процедура гф_ЗапроситьПродажиCactus()
	
	Попытка
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаПродажCactus.СтартОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаПродажКактус);
		ОбработкаЗапуска = Обработки.гф_ЗагрузкаПродажКактус.Создать();
		ОбработкаЗапуска.ВыполнитьОсновныеДействия();
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаПродажCactus.ЗавершениеОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаПродажКактус);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаПродажCactus.ОшибкаПриЗапуске", УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Обработки.гф_ЗагрузкаПродажКактус,,СтрокаСообщения);
	КонецПопытки;
	
	ПродолжитьВызов(); 
	
КонецПроцедуры

// #wortmann {
// Метод регламентного задания "Создание заказов на эмиссию кодов маркировки"
// Галфинд Sakovich 2022/11/30
&Вместо("СоздатьДокументыЗаказЭмиссииКодовМаркировки")
Процедура гф_СоздатьДокументыЗаказЭмиссииКодовМаркировки()
	
	Попытка
		ЗаписьЖурналаРегистрации("ЗапускОбработкиСозданияЭмиссииКМ.СтартОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ);
		ОбработкаЗапуска = Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ.Создать();
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("ЗапускОбработкиСозданияЭмиссииКМ.ОшибкаПриЗапуске", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ,,СтрокаСообщения);
		Возврат;
	КонецПопытки;

	Попытка
		ЗаписьЖурналаРегистрации("РегламентноеСозданиеДокументовЭмиссииКМ.СозданиеДокументовЭмиссии", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ);
		РезультатСозданияЭмиссии = Неопределено;
		ОбработкаЗапуска.СоздатьДокументыЗаказНаЭмиссиюКодовМаркировки(РезультатСозданияЭмиссии);
		ЗаписьЖурналаРегистрации("РегламентноеСозданиеДокументовЭмиссииКМ.ЗавершениеСозданияДокументовЭмиссии", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при создании документов Эмиссии КМ: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентноеСозданиеДокументовЭмиссииКМ.ОшибкаПриСозданииДокументовЭмиссии", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ,,СтрокаСообщения);
	КонецПопытки;
	
	ПродолжитьВызов();
КонецПроцедуры // } #wortmann

// #wortmann {
// #4.1 Создание документов движений КМ Внешних систем
// Метод регламентного задания "Создание документов движения кодов маркироваки внешних систем"
// Галфинд (Уфимцев) Перминов 2022/12/06
&Вместо("СозданиеДокументовДвиженийКМВнешнихСистем")
Процедура гф_СозданиеДокументовДвиженийКМВнешнихСистем()
	
	Попытка
		ЗаписьЖурналаРегистрации("РегламентноеСозданиеДокументовДвиженийКодовМаркировкиВнешнихСистем.СтартОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_СозданиеДокументовДвиженийКМВнешнихСистем);
		ОбработкаЗапуска = Обработки.гф_СозданиеДокументовДвиженийКМВнешнихСистем.Создать();
		ОбработкаЗапуска.ВыполнитьОсновныеДействия();
		ЗаписьЖурналаРегистрации("РегламентноеСозданиеДокументовДвиженийКодовМаркировкиВнешнихСистем.ЗавершениеОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_СозданиеДокументовДвиженийКМВнешнихСистем);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентноеСозданиеДокументовДвиженийКодовМаркировкиВнешнихСистем.ОшибкаПриЗапуске", УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Обработки.гф_СозданиеДокументовДвиженийКМВнешнихСистем,,СтрокаСообщения);
	КонецПопытки;
	
	ПродолжитьВызов();
	
КонецПроцедуры// } #wortmann

// #wortmann {
// Метод регламентного задания "Загрузка файлов и писем"
// Галфинд Домнышева 2022/12/19
&Вместо("ЗагрузитьФайлыИПисьма")
Процедура гф_ЗагрузитьФайлыИПисьма()
	
	Попытка
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаФайловИзПочты.СтартОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаФайловИзПочты);
		ОбработкаЗапуска = Обработки.гф_ЗагрузкаФайловИзПочты.Создать();
		ОбработкаЗапуска.ЗагрузкаФайловИзПочты();
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаФайловИзПочты.ЗавершениеОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаФайловИзПочты);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаФайловИзПочты.ОшибкаПриЗапуске", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаФайловИзПочты,,СтрокаСообщения);
	КонецПопытки;

	ПродолжитьВызов(); 
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #7.2 Движения КМ Wildberries
// Метод регламентного задания Загрузка движений КМ Wildberries
// Галфинд (Уфимцев) Перминов 2022/12/28
&Вместо("ЗапроситьДвиженияКМWildberries")
Процедура гф_ЗапроситьДвиженияКМWildberries()

	Попытка
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаДвиженийКМWildberries.СтартОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаПродажWildberries);
		ОбработкаЗапуска = Обработки.гф_ЗагрузкаПродажWildberries.Создать();
		ОбработкаЗапуска.ВыполнитьКоманду("ЗагрузкаДвиженийКМWildberriesAPI");
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаДвиженийКМWildberries.ЗавершениеОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаПродажWildberries);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаДвиженийКМWildberries.ОшибкаПриЗапуске", УровеньЖурналаРегистрации.Ошибка,
			Метаданные.Обработки.гф_ЗагрузкаПродажWildberries,,СтрокаСообщения);
	КонецПопытки;
	
	ПродолжитьВызов();
КонецПроцедуры// } #wortmann

// #wortmann {
// Метод регламентного задания "Загрузка файлов из I5"
// Галфинд Домнышева 2022/12/29
&Вместо("ЗагрузитьФайлыИзИ5")
Процедура гф_ЗагрузитьФайлыИзИ5()
	
	Попытка
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаФайловИзИ5.СтартОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаИзI5);
		ОбработкаЗапуска = Обработки.гф_ЗагрузкаИзI5.Создать();
		ОбработкаЗапуска.ВыполнитьЗагрузкуИРазборФайлов();
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаФайловИзИ5.ЗавершениеОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаИзI5);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаФайловИзИ5.ОшибкаПриЗапуске", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаИзI5,,СтрокаСообщения); 
	Возврат; // Галфинд_ДомнышеваКР_12_12_2023
	КонецПопытки;
	
	// ++ Галфинд_ДомнышеваКР_12_12_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee822b261c6d64
	Попытка
		ЗаписьЖурналаРегистрации("РегламентнаяОбработкаФайловИзИ5ЗагруженныхРанее.Обработка", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаИзI5);
		ОбработкаЗапуска.ОбработкаРанееСозданныхДокументов();
		ЗаписьЖурналаРегистрации("РегламентнаяОбработкаФайловИзИ5ЗагруженныхРанее.ЗавершениеОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаИзI5);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентнаяОбработкаФайловИзИ5ЗагруженныхРанее.ОшибкаПриЗапуске", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаИзI5,,СтрокаСообщения);
	КонецПопытки;
	// -- Галфинд_ДомнышеваКР_12_12_2023

	ПродолжитьВызов();
КонецПроцедуры// } #wortmann

// #wortmann {
// Метод регламентного задания "Загрузка инвойс"
// Галфинд Домнышева 2023/02/17
&Вместо("ЗагрузитьФайлыИнвойс")
Процедура гф_ЗагрузитьФайлыИнвойс()
	
	Попытка
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаИнвойс.СтартОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаИнвойс);
		ОбработкаЗапуска = Обработки.гф_ЗагрузкаИнвойс.Создать();
		ОбработкаЗапуска.ВыполнитьЗагрузкуИРазборФайлов();
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаИнвойс.ЗавершениеОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаИнвойс);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаИнвойс.ОшибкаПриЗапуске", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ЗагрузкаИнвойс,,СтрокаСообщения);
	КонецПопытки;

	//// ++ Галфинд СадомцевСА 27.11.2023 Функционал перенесен
	//// Из регл. задания гф_ОтработкаСтатусовКМ_в_документах (Отработка статусов КМ в документах)
	//// В регл. задание гф_ЗагрузкаИнвойс (Загрузка файлов инвойс и шиппинг лист)
	//// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee733580744246
	//Попытка
	//	ЗаписьЖурналаРегистрации("ЗапускОбработкиСозданияЭмиссииКМ.СтартОбработки",
	//		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ);
	//	ОбработкаЗапуска = Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ.Создать();
	//Исключение
	//	ТекстОшибки = ОписаниеОшибки();
	//	СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
	//	ЗаписьЖурналаРегистрации("ЗапускОбработкиСозданияЭмиссииКМ.ОшибкаПриЗапуске", 
	//	УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ,,СтрокаСообщения);
	//	Возврат;
	//КонецПопытки;
	//
	//Попытка
	//	ОбработкаЗапуска.ПроверитьУстановитьСтатусыКМЭмитированы(Истина);
	//	ЗаписьЖурналаРегистрации("ЗапускОбработкиСозданияЭмиссииКМ.ФинишОбработки",
	//		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ);
	//Исключение
	//	ТекстОшибки = ОписаниеОшибки();
	//	СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
	//	ЗаписьЖурналаРегистрации("ЗапускОбработкиСозданияЭмиссииКМ.ОшибкаПриЗапуске", 
	//		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ,,СтрокаСообщения);
	//	Возврат;
	//КонецПопытки;
	//// -- Галфинд СадомцевСА 27.11.2023

	ПродолжитьВызов();
КонецПроцедуры

// Метод регламентного задания "Корректировка назначений"
// ++ ЛигаКода Сгонник 2023/02/21
&Вместо("КорректировкаНазначений")
Процедура гф_КорректировкаНазначений()
	
	Попытка       
		
		ЗаписьЖурналаРегистрации("РегламентнаяКорректировкаНазначений.СтартОбработки"
		, УровеньЖурналаРегистрации.Информация
		, Метаданные.Обработки.гф_КорректировкаНазначений);
		
		ОбработкаЗапуска = Обработки.гф_КорректировкаНазначений.Создать();
		
		ОбработкаЗапуска.ВыполнитьКоманду("гф_КорректировкаНазначенийАвтоматически");
		
		ЗаписьЖурналаРегистрации("РегламентнаяКорректировкаНазначений.ЗавершениеОбработки"
		, УровеньЖурналаРегистрации.Информация
		, Метаданные.Обработки.гф_КорректировкаНазначений);
		
	Исключение 
		
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		
		ЗаписьЖурналаРегистрации("РегламентнаяКорректировкаНазначений.ОшибкаПриЗапуске"		
		, УровеньЖурналаРегистрации.Ошибка
		, Метаданные.Обработки.гф_КорректировкаНазначений
		,
		,СтрокаСообщения);
		
	КонецПопытки;

	ПродолжитьВызов();
КонецПроцедуры

// #wortmann {
// Метод регламентного задания "Сопоставление приходных ордеров и заявок на возврат"
// Галфинд Sakovich 2023/03/30
&Вместо("СопоставитьПриходныеОрдераИЗаявкиНаВозврат")
Процедура гф_СопоставитьПриходныеОрдераИЗаявкиНаВозврат()
	Попытка
		ЗаписьЖурналаРегистрации("ЗапускОбработкиСопоставлениеОрдеровИЗаявокНаВозврат.СтартОбработки", 
		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_СопоставлениеОрдеровИЗаявокНаВозврат);
		ОбработкаЗапуска = Обработки.гф_СопоставлениеОрдеровИЗаявокНаВозврат.Создать();
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("ЗапускОбработкиСопоставлениеОрдеровИЗаявокНаВозврат.ОшибкаПриЗапуске", 
		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_СопоставлениеОрдеровИЗаявокНаВозврат,,
		СтрокаСообщения);
		Возврат;
	КонецПопытки;

	Попытка
		ЗаписьЖурналаРегистрации("РегламентноеСопоставлениеОрдеровИЗаявокНаВозврат.СопоставлениеДокументов", 
		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_СопоставлениеОрдеровИЗаявокНаВозврат);
		РезультатВыполнения = Неопределено;
		ОбработкаЗапуска.ВыполнитьСопоставлениеПрОрдеровИЗаявокНаВозврат(РезультатВыполнения);
		ЗаписьЖурналаРегистрации("РегламентноеСопоставлениеОрдеровИЗаявокНаВозврат.ЗавершениеСопоставленияДокументов", 
		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_СопоставлениеОрдеровИЗаявокНаВозврат);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при сопоставлении прих.ордеров и заявок на возврат: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентноеСопоставлениеОрдеровИЗаявокНаВозврат.ОшибкаПриСопоставленииДокументов", 
		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_СопоставлениеОрдеровИЗаявокНаВозврат,,СтрокаСообщения);
		Возврат;
	КонецПопытки;

	ПродолжитьВызов();
КонецПроцедуры

// #wortmann {
// Метод регламентного задания "Отработка статусов КМ в документах"
// Галфинд Sakovich 2023/03/30
&Вместо("ОтработкаСтатусовКМ_в_документах")
Процедура гф_ОтработкаСтатусовКМ_в_документах()
	Попытка
		ЗаписьЖурналаРегистрации("ЗапускОбработкиСозданияЭмиссииКМ.СтартОбработки",
		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ);
		ОбработкаЗапуска = Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ.Создать();
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("ЗапускОбработкиСозданияЭмиссииКМ.ОшибкаПриЗапуске", 
		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ,,СтрокаСообщения);
		Возврат;
	КонецПопытки;
	
	Попытка
		ЗаписьЖурналаРегистрации("РегламентноеСозданиеДокументовЭмиссииКМ.ОтработкаСтатусовКМ_в_документах", 
		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ);
		ОбработкаЗапуска.ПроверитьУстановитьСтатусыКМЭмитированы();
		ЗаписьЖурналаРегистрации("РегламентноеСозданиеДокументовЭмиссииКМ.ЗавершениеОтработкиСтатусовКМ_в_документах", 
		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при обработке статусов ""КМ Эмитированы"": "  + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентноеСозданиеДокументовЭмиссииКМ.ОшибкаПриОтработкеСтатусовКМ_в_документах", 
		УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ,,СтрокаСообщения);
		Возврат;
	КонецПопытки;
	
	ПродолжитьВызов();
КонецПроцедуры

// #wortmann {
// Метод регламентного задания "Подготовить документы Заказ на эмиссию КМ к передаче ИСМП"
// Галфинд СадомцевСА 2023/05/23
&Вместо("ПодготовитьДокументыЗаказНаЭмиссиюКМкПередачеИСМП")
Процедура гф_ПодготовитьДокументыЗаказНаЭмиссиюКМкПередачеИСМП()
	Попытка
		СтрокаСообщения = "Запуск регл. задания.";
		ЗаписьЖурналаРегистрации("РегламентированноеЗаданиеПодготовитьДокументыЗаказНаЭмиссиюКМкПередачеИСМП",
		УровеньЖурналаРегистрации.Информация,
		Метаданные.РегламентныеЗадания.гф_ПодготовитьДокументыЗаказНаЭмиссиюКМкПередачеИСМП,
		,СтрокаСообщения);
		МассивДокументов = ПодготовитьМассивДокументовЗаказНаЭмиссиюКМ();
		Если МассивДокументов.Количество() > 0 Тогда
			гф_ЭмиссияКодовМаркировкиВызовСервера.гф_ПодготовитьКПередачеИСМП(МассивДокументов, Истина);
		КонецЕсли;
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при выполнении регламентного задания: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентированноеЗаданиеПодготовитьДокументыЗаказНаЭмиссиюКМкПередачеИСМП",
		УровеньЖурналаРегистрации.Информация,
		Метаданные.РегламентныеЗадания.гф_ПодготовитьДокументыЗаказНаЭмиссиюКМкПередачеИСМП,
		,СтрокаСообщения);
		Возврат;
	КонецПопытки;
	
	ПродолжитьВызов();
КонецПроцедуры

Функция ПодготовитьМассивДокументовЗаказНаЭмиссиюКМ()
	МассивДокументов = Новый Массив;
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
               |	Таблица.Ссылка КАК Ссылка,
               |	Таблица.ПометкаУдаления КАК ПометкаУдаления,
               |	Таблица.Номер КАК Номер,
               |	Таблица.Дата КАК Дата,
               |	Таблица.Проведен КАК Проведен,
               |	Таблица.ДокументОснование КАК ДокументОснование,
               |	Таблица.Организация КАК Организация,
               |	Таблица.ВидПродукции КАК ВидПродукции,
               |	Таблица.СпособВводаВОборот КАК СпособВводаВОборот,
               |	Таблица.Ответственный КАК Ответственный,
               |	Статусы.Статус КАК СтатусИСМП,
               |	Статусы.ДальнейшееДействие1 КАК ДальнейшееДействиеИСМП1,
               |	ОчередьСообщенийИСМП.Сообщение КАК Сообщение
               |ИЗ
               |	Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК Таблица
               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СтатусыДокументовИСМП КАК Статусы
               |		ПО (Статусы.Документ = Таблица.Ссылка)
               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ОчередьСообщенийИСМП КАК ОчередьСообщенийИСМП
               |		ПО (ОчередьСообщенийИСМП.Документ = Таблица.Ссылка)
               |ГДЕ
			   // Галфинд СадомцевСА 16.08.2023 Исправил "ошибки" СонарКуба: убрал "условие с ИЛИ" из "раздела ГДЕ".
			   // добавил раздел "ОБЪЕДИНИТЬ ВСЕ"
			   |	Таблица.ДокументОснование.Проведен
			   |	И НЕ Таблица.ДокументОснование ССЫЛКА Документ.ПересортицаТоваров
			   |	И Статусы.ДальнейшееДействие1 = ЗНАЧЕНИЕ(Перечисление.ДальнейшиеДействияПоВзаимодействиюИСМП.ЗапроситеКодыМаркировки)
			   |	И ОчередьСообщенийИСМП.Сообщение ЕСТЬ NULL
               |ОБЪЕДИНИТЬ ВСЕ
               |ВЫБРАТЬ
               |	Таблица.Ссылка КАК Ссылка,
               |	Таблица.ПометкаУдаления КАК ПометкаУдаления,
               |	Таблица.Номер КАК Номер,
               |	Таблица.Дата КАК Дата,
               |	Таблица.Проведен КАК Проведен,
               |	Таблица.ДокументОснование КАК ДокументОснование,
               |	Таблица.Организация КАК Организация,
               |	Таблица.ВидПродукции КАК ВидПродукции,
               |	Таблица.СпособВводаВОборот КАК СпособВводаВОборот,
               |	Таблица.Ответственный КАК Ответственный,
               |	Статусы.Статус КАК СтатусИСМП,
               |	Статусы.ДальнейшееДействие1 КАК ДальнейшееДействиеИСМП1,
               |	ОчередьСообщенийИСМП.Сообщение КАК Сообщение
               |ИЗ
               |	Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК Таблица
               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СтатусыДокументовИСМП КАК Статусы
               |		ПО (Статусы.Документ = Таблица.Ссылка)
               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ОчередьСообщенийИСМП КАК ОчередьСообщенийИСМП
               |		ПО (ОчередьСообщенийИСМП.Документ = Таблица.Ссылка)
               |ГДЕ
			   // Галфинд СадомцевСА 07.08.2023 Исправил "ошибки" СонарКуба: убрал "условие с ИЛИ" из "раздела ГДЕ".
			   // добавил раздел "ОБЪЕДИНИТЬ ВСЕ"
			   |	Таблица.ДокументОснование ССЫЛКА Документ.ПересортицаТоваров
			   |	И Статусы.ДальнейшееДействие1 = ЗНАЧЕНИЕ(Перечисление.ДальнейшиеДействияПоВзаимодействиюИСМП.ЗапроситеКодыМаркировки)
			   |	И ОчередьСообщенийИСМП.Сообщение ЕСТЬ NULL";
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Если МассивДокументов.Найти(Выборка.Ссылка) = Неопределено Тогда
			МассивДокументов.Добавить(Выборка.Ссылка);
		КонецЕсли;
	КонецЦикла;
	Возврат МассивДокументов;
КонецФункции

// #wortmann {
// Метод регламентного задания "Маркировка товаров (ввод в оборот)"
// Галфинд СадомцевСА 2023/05/24
&Вместо("МаркировкаТоваровВводВОборот")
Процедура гф_МаркировкаТоваровВводВОборот()
	Попытка
		СтрокаСообщения = "Запуск регл. задания.";
		ЗаписьЖурналаРегистрации("РегламентированноеЗаданиеМаркировкаТоваровВводВОборот",
		УровеньЖурналаРегистрации.Информация,
		Метаданные.РегламентныеЗадания.гф_МаркировкаТоваровВводВОборот,
		,СтрокаСообщения);
		ТЗДокументов = ПодготовитьТЗДокументовПТУ();
		Если ТЗДокументов.Количество() > 0 Тогда
			МассивМаркировки = Новый Массив;
			Для Каждого СтрокаТЗ Из ТЗДокументов Цикл
				СтруктураВозврата = гф_МаркировкаТоваровИСМПВызовСервера.гф_СоздатьМаркировкаТоваровИСМП(СтрокаТЗ);
				Если ЗначениеЗаполнено(СтруктураВозврата["МаркировкаТоваровИСМП"])
					И СтруктураВозврата["ЕстьОшибкиЗаполнения"] = Ложь Тогда
					МассивМаркировки.Добавить(СтруктураВозврата["МаркировкаТоваровИСМП"]);
				КонецЕсли;
			КонецЦикла;
			Если МассивМаркировки.Количество() > 0 Тогда
				гф_МаркировкаТоваровИСМПВызовСервера.гф_ПодготовитьКПередачеИСМП(МассивМаркировки);
			КонецЕсли;
		КонецЕсли;
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при выполнении регл. задания: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентированноеЗаданиеМаркировкаТоваровВводВОборот",
		УровеньЖурналаРегистрации.Информация,
		Метаданные.РегламентныеЗадания.гф_МаркировкаТоваровВводВОборот,
		,СтрокаСообщения);
		Возврат;
	КонецПопытки;
	
	ПродолжитьВызов();
КонецПроцедуры

Функция ПодготовитьТЗДокументовПТУ()
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	ТаможеннаяДекларацияИмпортТовары.Ссылка КАК Ссылка,
	|	ТаможеннаяДекларацияИмпортТовары.Ссылка.Проведен КАК Проведен,
	|	ЕСТЬNULL(ДополнительныеРеквизиты.Значение, ЛОЖЬ) КАК КМВведеныВОборот,
	|	ТаможеннаяДекларацияИмпортТовары.ДокументПоступления КАК ДокументПоступления,
	|	Маркировка.Ссылка КАК Маркировка,
	|	Маркировка.Проведен КАК МаркировкаПроведен,
	|	СтатусыДокументовИСМП.Статус КАК Статус,
	|	СтатусыДокументовИСМП.ДальнейшееДействие1 КАК ДальнейшееДействие1,
	|	СтатусыДокументовИСМП.ДальнейшееДействие2 КАК ДальнейшееДействие2,
	|	СтатусыДокументовИСМП.ДальнейшееДействие3 КАК ДальнейшееДействие3
	|ПОМЕСТИТЬ втГТД
	|ИЗ
	|	Документ.ТаможеннаяДекларацияИмпорт.Товары КАК ТаможеннаяДекларацияИмпортТовары
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ТаможеннаяДекларацияИмпорт.ДополнительныеРеквизиты КАК ДополнительныеРеквизиты
	|		ПО (ДополнительныеРеквизиты.Ссылка = ТаможеннаяДекларацияИмпортТовары.Ссылка)
	|			И (ДополнительныеРеквизиты.Свойство = &Свойство)
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.МаркировкаТоваровИСМП КАК Маркировка
	|		ПО (Маркировка.ДокументОснование = ТаможеннаяДекларацияИмпортТовары.ДокументПоступления)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СтатусыДокументовИСМП КАК СтатусыДокументовИСМП
	|		ПО (СтатусыДокументовИСМП.Документ = Маркировка.Ссылка)
	|ГДЕ
	|	ТаможеннаяДекларацияИмпортТовары.Ссылка.Проведен
	|	И ВЫБОР
	|			КОГДА ЕСТЬNULL(ДополнительныеРеквизиты.Значение, ЛОЖЬ) = ЛОЖЬ
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ ЛОЖЬ
	|		КОНЕЦ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаможеннаяДекларацияИмпорт.Ссылка КАК ГТД,
	|	ТаможеннаяДекларацияИмпорт.ДокументПоступления КАК ДокументПоступления,
	|	МАКСИМУМ(ТаможеннаяДекларацияИмпорт.Маркировка) КАК Маркировка
	|ИЗ
	|	втГТД КАК ТаможеннаяДекларацияИмпорт
	|
	|СГРУППИРОВАТЬ ПО
	|	ТаможеннаяДекларацияИмпорт.Ссылка,
	|	ТаможеннаяДекларацияИмпорт.ДокументПоступления
	|
	|ИМЕЮЩИЕ
	|	МАКСИМУМ(ТаможеннаяДекларацияИмпорт.Маркировка) ЕСТЬ NULL";
	ДопРеквизит = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту(
		"ИдентификаторДляФормул", "гф_КМВведеныВОборот");
	Запрос.УстановитьПараметр("Свойство", ДопРеквизит);
	Результат = Запрос.Выполнить();
	ТЗ = Результат.Выгрузить();
	Возврат ТЗ;
КонецФункции

// #wortmann {
// Метод регламентного задания "Обработка пересортицы"
// Галфинд Sakovich 2023/05/30
&Вместо("ОбработкаПересортицы")
Процедура гф_ОбработкаПересортицы()
	Попытка
		СтрокаСообщения = "Запуск регл. задания.";
		ЗаписьЖурналаРегистрации("РегламентированноеЗаданиеОбработкаПересортицы",
		УровеньЖурналаРегистрации.Информация,
		Метаданные.РегламентныеЗадания.гф_ОбработкаПересортицы,
		,СтрокаСообщения);
		
		гф_ОбработкаИсключенийПоКоробамВызовСервера.ОбработкаПересортицы();
		
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при выполнении регламентного задания: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентированноеЗаданиеОбработкаПересортицы",
		УровеньЖурналаРегистрации.Информация,
		Метаданные.РегламентныеЗадания.гф_ОбработкаПересортицы,
		,СтрокаСообщения);
		Возврат;
	КонецПопытки;
	
	ПродолжитьВызов();
КонецПроцедуры

// #wortmann {
// Метод регламентного задания "Таможенная декларация импорт установить КМ введены в оборот"
// Галфинд СадомцевСА 2023/06/02
&Вместо("ТаможеннаяДекларацияИмпортУстановитьКМВведеныВОборот")
Процедура гф_ТаможеннаяДекларацияИмпортУстановитьКМВведеныВОборот()
	Попытка
		СтрокаСообщения = "Запуск регл. задания.";
		ЗаписьЖурналаРегистрации("РегламентированноеЗаданиеТаможеннаяДекларацияИмпортУстановитьКМВведеныВОборот",
		УровеньЖурналаРегистрации.Информация,
		Метаданные.РегламентныеЗадания.гф_ТаможеннаяДекларацияИмпортУстановитьКМВведеныВОборот,
		,СтрокаСообщения);
		ГТДУстановитьКМВведеныВОборот();
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при выполнении регламентного задания: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентированноеЗаданиеТаможеннаяДекларацияИмпортУстановитьКМВведеныВОборот",
		УровеньЖурналаРегистрации.Информация,
		Метаданные.РегламентныеЗадания.гф_ТаможеннаяДекларацияИмпортУстановитьКМВведеныВОборот,
		,СтрокаСообщения);
		Возврат;
	КонецПопытки;
	
	ПродолжитьВызов();
КонецПроцедуры

Процедура ГТДУстановитьКМВведеныВОборот()
	ДопРеквизит = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту(
	"ИдентификаторДляФормул", "гф_КМВведеныВОборот");
	Если ДопРеквизит = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.ПустаяСсылка() Тогда
		Возврат;
	КонецЕсли;
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	ТаможеннаяДекларацияИмпортТовары.Ссылка КАК Ссылка,
	|	ТаможеннаяДекларацияИмпортТовары.Ссылка.Проведен КАК Проведен,
	|	ЕСТЬNULL(ДополнительныеРеквизиты.Значение, ЛОЖЬ) КАК КМВведеныВОборот,
	|	ТаможеннаяДекларацияИмпортТовары.ДокументПоступления КАК ДокументПоступления,
	|	Маркировка.Ссылка КАК Маркировка,
	|	Маркировка.Проведен КАК МаркировкаПроведен,
	|	СтатусыДокументовИСМП.Статус КАК Статус,
	|	ВЫБОР
	|		КОГДА СтатусыДокументовИСМП.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыОбработкиМаркировкиТоваровИСМП.КодыМаркировкиВведеныВОборот)
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК МаркировкаВведенаВОборот
	|ПОМЕСТИТЬ втГТД
	|ИЗ
	|	Документ.ТаможеннаяДекларацияИмпорт.Товары КАК ТаможеннаяДекларацияИмпортТовары
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ТаможеннаяДекларацияИмпорт.ДополнительныеРеквизиты КАК ДополнительныеРеквизиты
	|		ПО (ДополнительныеРеквизиты.Ссылка = ТаможеннаяДекларацияИмпортТовары.Ссылка)
	|			И (ДополнительныеРеквизиты.Свойство = &Свойство)
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.МаркировкаТоваровИСМП КАК Маркировка
	|		ПО (Маркировка.ДокументОснование = ТаможеннаяДекларацияИмпортТовары.ДокументПоступления)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СтатусыДокументовИСМП КАК СтатусыДокументовИСМП
	|		ПО (СтатусыДокументовИСМП.Документ = Маркировка.Ссылка)
	|ГДЕ
	|	ТаможеннаяДекларацияИмпортТовары.Ссылка.Проведен
	|	И ВЫБОР
	|			КОГДА ЕСТЬNULL(ДополнительныеРеквизиты.Значение, ЛОЖЬ) = ЛОЖЬ
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ ЛОЖЬ
	|		КОНЕЦ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ГТД.Ссылка КАК Ссылка,
	|	МИНИМУМ(ГТД.МаркировкаВведенаВОборот) КАК МаркировкаВведенаВОборот
	|ИЗ
	|	втГТД КАК ГТД
	|
	|СГРУППИРОВАТЬ ПО
	|	ГТД.Ссылка
	|
	|ИМЕЮЩИЕ
	|	МИНИМУМ(ГТД.МаркировкаВведенаВОборот) = ИСТИНА";
	Запрос.УстановитьПараметр("Свойство", ДопРеквизит);
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		ДокОбъект = Выборка.Ссылка.ПолучитьОбъект();
		СтрокаТЧ = ДокОбъект.ДополнительныеРеквизиты.Добавить();
		СтрокаТЧ.Свойство = ДопРеквизит;
		СтрокаТЧ.Значение = Истина;
		ДокОбъект.ОбменДанными.Загрузка = Истина;
		ДокОбъект.Записать();
	КонецЦикла;
КонецПроцедуры

// #wortmann {
// Метод регламентного задания "Подготовить документы Маркировка товаров к передаче ИСМП"
// Галфинд СадомцевСА 2023/06/05
&Вместо("ПодготовитьДокументыМаркировкаТоваровКПередачеИСМП")
Процедура гф_ПодготовитьДокументыМаркировкаТоваровКПередачеИСМП()
	Попытка
		СтрокаСообщения = "Запуск регл. задания.";
		ЗаписьЖурналаРегистрации("РегламентированноеЗаданиеПодготовитьДокументыМаркировкаТоваровКПередачеИСМП",
		УровеньЖурналаРегистрации.Информация,
		Метаданные.РегламентныеЗадания.гф_ПодготовитьДокументыМаркировкаТоваровКПередачеИСМП,
		,СтрокаСообщения);
		МассивМаркировки = ПодготовитьМассивМаркировкиТоваров();
		Если МассивМаркировки.Количество() > 0 Тогда
			гф_МаркировкаТоваровИСМПВызовСервера.гф_ПодготовитьКПередачеИСМП(МассивМаркировки);
		КонецЕсли;
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при выполнении регламентного задания: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентированноеЗаданиеПодготовитьДокументыМаркировкаТоваровКПередачеИСМП",
		УровеньЖурналаРегистрации.Информация,
		Метаданные.РегламентныеЗадания.гф_ПодготовитьДокументыМаркировкаТоваровКПередачеИСМП,
		,СтрокаСообщения);
		Возврат;
	КонецПопытки;
	
	ПродолжитьВызов();
КонецПроцедуры

Функция ПодготовитьМассивМаркировкиТоваров()
	МассивДокументов = Новый Массив;
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Маркировка.Ссылка КАК Ссылка,
	|	Маркировка.Проведен КАК Проведен,
	|	СтатусыДокументовИСМП.Статус КАК Статус,
	|	ВЫБОР
	|		КОГДА СтатусыДокументовИСМП.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыОбработкиМаркировкиТоваровИСМП.КодыМаркировкиВведеныВОборот)
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК МаркировкаВведенаВОборот,
	|	ОчередьСообщенийИСМП.Сообщение КАК Сообщение
	|ИЗ
	|	Документ.МаркировкаТоваровИСМП КАК Маркировка
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СтатусыДокументовИСМП КАК СтатусыДокументовИСМП
	|		ПО (СтатусыДокументовИСМП.Документ = Маркировка.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ОчередьСообщенийИСМП КАК ОчередьСообщенийИСМП
	|		ПО (ОчередьСообщенийИСМП.Документ = Маркировка.Ссылка)
	|ГДЕ
	|	Маркировка.Проведен
	|	И ВЫБОР
	|			КОГДА СтатусыДокументовИСМП.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыОбработкиМаркировкиТоваровИСМП.КодыМаркировкиВведеныВОборот)
	|				ТОГДА ЛОЖЬ
	|			КОГДА СтатусыДокументовИСМП.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыОбработкиМаркировкиТоваровИСМП.КодыМаркировкиАгрегированы)
	|				ТОГДА ЛОЖЬ
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ОчередьСообщенийИСМП.Сообщение ЕСТЬ NULL";
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если МассивДокументов.Найти(Выборка.Ссылка) = Неопределено Тогда
			МассивДокументов.Добавить(Выборка.Ссылка);
		КонецЕсли;
	КонецЦикла;
	Возврат МассивДокументов;
КонецФункции

// #wortmann {
// Метод регламентного задания "ОбработкаУдаления"
// Галфинд Sakovich 2023/06/07
&Вместо("ОбработкаУдаления")
Процедура гф_ОбработкаУдаления()
	Попытка
		СтрокаСообщения = "Запуск регл. задания.";
		ЗаписьЖурналаРегистрации("РегламентированноеЗаданиеОбработкаУдаления",
		УровеньЖурналаРегистрации.Информация,
		Метаданные.РегламентныеЗадания.гф_ОбработкаУдаления,
		,СтрокаСообщения);
		
		гф_ОбработкаИсключенийПоКоробамВызовСервера.ОбработкаУдаления();
		
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при выполнении регламентного задания: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентированноеЗаданиеОбработкаУдаления",
		УровеньЖурналаРегистрации.Информация,
		Метаданные.РегламентныеЗадания.гф_ОбработкаУдаления,
		,СтрокаСообщения);
		Возврат;
	КонецПопытки;
	
	ПродолжитьВызов();
	
КонецПроцедуры

// #wortmann {
// Метод регламентного задания "ГенерацияЭлементовМаркированныйТовар"
// Галфинд Sakovich 2023/06/08
&Вместо("ГенерацияЭлементовМаркированныйТовар")
Процедура гф_ГенерацияЭлементовМаркированныйТовар()
	гф_ЭмиссияКодовМаркировкиВызовСервера.ПроверитьСоздатьЭлементыМаркированныйТовар();
	ПродолжитьВызов();
КонецПроцедуры

// #wortmann {
// Метод регламентного задания "Обработка обмена с WMS (загрузка)"
// Галфинд Домнышева 2023/07/06
&Вместо("ЗагрузитьФайлыИзWMS")
Процедура гф_ЗагрузитьФайлыИзWMS()
	
	Попытка
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаФайловИзWMS.СтартОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ОбменСWMS);
		ОбработкаЗапуска = Обработки.гф_ОбменСWMS.Создать();
		ОбработкаЗапуска.ЗагрузитьДанные();
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаФайловИзWMS.ЗавершениеОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ОбменСWMS);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаФайловИзWMS.ОшибкаПриЗапуске", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ОбменСWMS,,СтрокаСообщения);
	КонецПопытки;

	ПродолжитьВызов();
КонецПроцедуры// } #wortmann

// #wortmann {
// Метод регламентного задания "Обработка обмена с WMS (выгрузка)"
// Галфинд Домнышева 2023/07/06
&Вместо("ВыгрузитьФайлыВWMS")
Процедура гф_ВыгрузитьФайлыВWMS()
	
	Попытка
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаФайловИзWMS.СтартОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ОбменСWMS);
		ОбработкаЗапуска = Обработки.гф_ОбменСWMS.Создать();
		ОбработкаЗапуска.ВыгрузитьДанные();
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаФайловИзWMS.ЗавершениеОбработки", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ОбменСWMS);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ЗаписьЖурналаРегистрации("РегламентнаяЗагрузкаФайловИзWMS.ОшибкаПриЗапуске", УровеньЖурналаРегистрации.Информация,
			Метаданные.Обработки.гф_ОбменСWMS,,СтрокаСообщения);
	КонецПопытки;

	ПродолжитьВызов();
КонецПроцедуры// } #wortmann
