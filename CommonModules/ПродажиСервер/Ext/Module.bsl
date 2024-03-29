﻿// BSLLS:CommonModuleMissingAPI-off
#Область ПроцедурыИФункцииПолученияЗначенийРеквизитовПоУмолчанию

&ИзменениеИКонтроль("ПолучитьДоговорПоУмолчанию")
Функция гф_ПолучитьДоговорПоУмолчанию(Объект, ХозяйственныеОперации, ВалютаВзаиморасчетов, НаправлениеДеятельности, КомиссионныеПродажи25)

	Если Не ПолучитьФункциональнуюОпцию("ИспользоватьДоговорыСКлиентами") Тогда
		Возврат Справочники.ДоговорыКонтрагентов.ПустаяСсылка();
	КонецЕсли;

	Если ПолучитьФункциональнуюОпцию("ИспользоватьСоглашенияСКлиентами")
		И ОбщегоНазначенияУТКлиентСервер.ЕстьРеквизитОбъекта(Объект, "Соглашение") Тогда 

		ПоСоглашениюИспользуютсяДоговорыКонтрагентов = ЗначениеЗаполнено(Объект.Соглашение)
		И ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Соглашение, "ИспользуютсяДоговорыКонтрагентов");

		Если Не ПоСоглашениюИспользуютсяДоговорыКонтрагентов Тогда
			Возврат Справочники.ДоговорыКонтрагентов.ПустаяСсылка();
		КонецЕсли;

	КонецЕсли;

	СписокПартнеров = Новый СписокЗначений;
	ПартнерыИКонтрагенты.ЗаполнитьСписокПартнераСРодителями(Объект.Партнер, СписокПартнеров);
    #Вставка
	// #wortmann {
	// Производится посик Основного Договора Контрагента, если договор найден - устанавливается соответствующее значение,
	// если нет, отрабатывает стандартная логика с поиском договоров
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed2a9589c5dc21
	// Галфинд_Домнышева 2022/09/05
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Контрагентыгф_ОсновнойДоговорКонтрагента.ОсновнойДоговор КАК ОсновнойДоговор,
		|	Контрагентыгф_ОсновнойДоговорКонтрагента.ОсновнойДоговор.Партнер КАК Партнер,
		|	Контрагентыгф_ОсновнойДоговорКонтрагента.ОсновнойДоговор.РазрешенаРаботаСДочернимиПартнерами
		|															КАК РазрешенаРаботаСДочернимиПартнерами
		|ИЗ
		|	Справочник.Контрагенты.гф_ОсновнойДоговорКонтрагента КАК Контрагентыгф_ОсновнойДоговорКонтрагента
		|ГДЕ
		|	Контрагентыгф_ОсновнойДоговорКонтрагента.Ссылка = &Контрагент
		|	И Контрагентыгф_ОсновнойДоговорКонтрагента.Организация = &Организация
		|	И Контрагентыгф_ОсновнойДоговорКонтрагента.ОсновнойДоговор.Партнер В(&СписокПартнеров)";
	
	Запрос.УстановитьПараметр("Контрагент", Объект.Контрагент);
	Запрос.УстановитьПараметр("Организация", Объект.Организация);
	Запрос.УстановитьПараметр("СписокПартнеров", СписокПартнеров);
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();

	Если Не РезультатЗапроса.Пустой() Тогда
		
	Выборка.Следующий();
	
	ДоговорПоУмолчанию = Выборка.ОсновнойДоговор;
	ПартнерДоговора = Выборка.Партнер;
	РазрешенаРаботаСДочернимиПартнерами = Выборка.РазрешенаРаботаСДочернимиПартнерами;

	Иначе
	// } #wortmann
	#КонецВставки
	
	Запрос = Новый Запрос("
	|ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Ссылка,
	|	ДоговорыКонтрагентов.Партнер,
	|	ДоговорыКонтрагентов.РазрешенаРаботаСДочернимиПартнерами
	|
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|
	|ГДЕ
	|	(НЕ ДоговорыКонтрагентов.ПометкаУдаления)
	|	И ДоговорыКонтрагентов.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыДоговоровКонтрагентов.Действует)
	|	И ДоговорыКонтрагентов.Партнер В (&СписокПартнеров)
	|	И ДоговорыКонтрагентов.Контрагент = &Контрагент
	|	И ДоговорыКонтрагентов.Организация = &Организация
	|	И ((НЕ &ОтборХозяйственнаяОперация)
	|			ИЛИ ДоговорыКонтрагентов.ХозяйственнаяОперация В (&ХозяйственнаяОперация))
	|	И ((НЕ &ОтборВалютаВзаиморасчетов)
	|			ИЛИ ДоговорыКонтрагентов.ВалютаВзаиморасчетов = &ВалютаВзаиморасчетов)
	|	И ДоговорыКонтрагентов.Ссылка = &ТекущийДоговор
	|	И ((НЕ &ОтборНаправлениеДеятельности)
	|			ИЛИ ДоговорыКонтрагентов.НаправлениеДеятельности = &НаправлениеДеятельности)
	|	И ((НЕ &ОтборКомиссионныеПродажи25)
	|			ИЛИ ДоговорыКонтрагентов.КомиссионныеПродажи25 = &КомиссионныеПродажи25);
	|
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 2
	|	ДоговорыКонтрагентов.Ссылка,
	|	ДоговорыКонтрагентов.Партнер,
	|	ДоговорыКонтрагентов.РазрешенаРаботаСДочернимиПартнерами
	|
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|
	|ГДЕ
	|	(НЕ ДоговорыКонтрагентов.ПометкаУдаления)
	|	И ДоговорыКонтрагентов.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыДоговоровКонтрагентов.Действует)
	|	И ДоговорыКонтрагентов.Партнер В (&СписокПартнеров)
	|	И ДоговорыКонтрагентов.Контрагент = &Контрагент
	|	И ДоговорыКонтрагентов.Организация = &Организация
	|	И ((НЕ &ОтборХозяйственнаяОперация)
	|			ИЛИ ДоговорыКонтрагентов.ХозяйственнаяОперация В (&ХозяйственнаяОперация))
	|	И ((НЕ &ОтборВалютаВзаиморасчетов)
	|			ИЛИ ДоговорыКонтрагентов.ВалютаВзаиморасчетов = &ВалютаВзаиморасчетов)
	|	И ((НЕ &ОтборНаправлениеДеятельности)
	|			ИЛИ ДоговорыКонтрагентов.НаправлениеДеятельности = &НаправлениеДеятельности)
	|	И ((НЕ &ОтборКомиссионныеПродажи25)
	|			ИЛИ ДоговорыКонтрагентов.КомиссионныеПродажи25 = &КомиссионныеПродажи25)
	|");
	Запрос.УстановитьПараметр("ТекущийДоговор", Объект.Договор);
	Запрос.УстановитьПараметр("СписокПартнеров", СписокПартнеров);
	Запрос.УстановитьПараметр("Контрагент", Объект.Контрагент);
	Запрос.УстановитьПараметр("Организация", Объект.Организация);
	Запрос.УстановитьПараметр("ОтборХозяйственнаяОперация", ЗначениеЗаполнено(ХозяйственныеОперации));
	Запрос.УстановитьПараметр("ХозяйственнаяОперация", ХозяйственныеОперации);
	Запрос.УстановитьПараметр("ОтборВалютаВзаиморасчетов", ЗначениеЗаполнено(ВалютаВзаиморасчетов));
	Запрос.УстановитьПараметр("ВалютаВзаиморасчетов", ВалютаВзаиморасчетов);
	Запрос.УстановитьПараметр("ОтборНаправлениеДеятельности", НаправлениеДеятельности <> Неопределено
	И ПолучитьФункциональнуюОпцию("ИспользоватьУчетДоходовПоНаправлениямДеятельности"));
	Запрос.УстановитьПараметр("НаправлениеДеятельности",НаправлениеДеятельности);
	Запрос.УстановитьПараметр("ОтборКомиссионныеПродажи25", ЗначениеЗаполнено(КомиссионныеПродажи25));
	Запрос.УстановитьПараметр("КомиссионныеПродажи25", КомиссионныеПродажи25);

	МассивРезультатов = Запрос.ВыполнитьПакет();

	ПартнерДоговора = Справочники.Партнеры.ПустаяСсылка();
	РазрешенаРаботаСДочернимиПартнерами = Ложь;
	Если Не МассивРезультатов[0].Пустой() Тогда

		Выборка = МассивРезультатов[0].Выбрать();
		Выборка.Следующий();

		ДоговорПоУмолчанию = Выборка.Ссылка;

		ПартнерДоговора = Выборка.Партнер;
		РазрешенаРаботаСДочернимиПартнерами = Выборка.РазрешенаРаботаСДочернимиПартнерами;

	Иначе
		Выборка = МассивРезультатов[1].Выбрать();

		Если Не Выборка.Следующий() Тогда
			ДоговорПоУмолчанию = Справочники.ДоговорыКонтрагентов.ПустаяСсылка();
		ИначеЕсли Выборка.Количество() = 1 Тогда
			ДоговорПоУмолчанию = Выборка.Ссылка;	
			ПартнерДоговора = Выборка.Партнер;
			РазрешенаРаботаСДочернимиПартнерами = Выборка.РазрешенаРаботаСДочернимиПартнерами;
		Иначе
			ДоговорПоУмолчанию = Справочники.ДоговорыКонтрагентов.ПустаяСсылка();
		КонецЕсли;
	КонецЕсли;
    #Вставка
	// #wortmann {
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed2a9589c5dc21
	// Галфинд_Домнышева 2022/09/05
	КонецЕсли;
	// } #wortmann
	#КонецВставки
	
	Если НЕ РазрешенаРаботаСДочернимиПартнерами И ПартнерДоговора <> Объект.Партнер Тогда
		ДоговорПоУмолчанию = Справочники.ДоговорыКонтрагентов.ПустаяСсылка();	
	КонецЕсли;

	Возврат ДоговорПоУмолчанию;

КонецФункции

#КонецОбласти
// BSLLS:CommonModuleMissingAPI-on

#Область ПроцедурыПроверкиКорректностиЗаполненияДокументов

&Вместо("ПроверитьКорректностьВозвращаемыхТоваров")
Процедура гф_ПроверитьКорректностьВозвращаемыхТоваров(Знач ДокументПродажи, ИмяТаблицы, Отказ, ТаблицаПроверяемыеТовары)
	
	// #wortmann {
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee0b447eb8aee2
	// При уже созданной корректировки у док ЗаявкаНаВозврат проверка не должна производиться
	// Галфинд_ДомнышеваКР_15_06_2023
	Если УсловиеЗаявкиНаВозвратИЛИОснованияЗаявки(ДокументПродажи) Тогда
		Возврат;
	КонецЕсли;
	// } #wortmann

	// #wortmann {
	// 1.1 Регистрация возвратов	
	// Галфинд Sakovich 2022/11/29
	Если ТаблицаПроверяемыеТовары = Неопределено Тогда
		Если ИмяТаблицы = "ВозвращаемыеТовары" Тогда
			ПараметрыОтбора = Новый Структура("Отменено", Ложь); 
			ТаблицаПроверяемыеТовары = ДокументПродажи[ИмяТаблицы].Выгрузить(ПараметрыОтбора);
		Иначе
			ТаблицаПроверяемыеТовары = ДокументПродажи[ИмяТаблицы].Выгрузить();
		КонецЕсли;
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee0b447eb8aee2
		// При уже созданной корректировки у док ЗаявкаНаВозврат проверка не должна производиться
		// Галфинд_ДомнышеваКР_15_06_2023
		Если ТипЗнч(ДокументПродажи) = Тип("ДокументСсылка.ЗаявкаНаВозвратТоваровОтКлиента") 
			ИЛИ ТипЗнч(ДокументПродажи) = Тип("ДокументОбъект.ЗаявкаНаВозвратТоваровОтКлиента") Тогда 
			МассивСтрБезПроверки = Новый Массив;		 
			Для каждого СтрТЗ Из ТаблицаПроверяемыеТовары Цикл
				Если ЗначениеЗаполнено(СтрТЗ["гф_ДокументКорректировкаРеализации"]) Тогда
				МассивСтрБезПроверки.Добавить(СтрТЗ);
				КонецЕсли;
			КонецЦикла;
			
			Для Каждого Удаляемая Из МассивСтрБезПроверки Цикл
				ТаблицаПроверяемыеТовары.Удалить(Удаляемая);
			КонецЦикла;
		КонецЕсли;
		// } #wortmann
		
		ПоляГруппировки = "Номенклатура,Характеристика,Серия,Назначение,ДокументРеализации,СтатусУказанияСерий";
		ПоляСуммирования = "Количество, КоличествоУпаковок";
		
		ТаблицаПроверяемыеТовары.Свернуть(ПоляГруппировки, ПоляСуммирования);
				
		Для каждого СтрТЗ Из ТаблицаПроверяемыеТовары Цикл
			Если СтрТЗ["Назначение"]  = Справочники.Назначения.гф_Холд Тогда
				СтрТЗ["Назначение"]  = "";
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	// } #wortmann
	
	ПродолжитьВызов(ДокументПродажи, ИмяТаблицы, Отказ, ТаблицаПроверяемыеТовары);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции 

// #wortmann {
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee0b447eb8aee2
// Проверяет наличие ДокументовКорректировки в ТЧ Заявки
// Галфинд_ДомнышеваКР_15_06_2023
Функция КорректировкиЗаполненыВсе(ДокументПродажи)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЗаявкаНаВозвратТоваровОтКлиентаВозвращаемыеТовары.гф_ДокументКорректировкаРеализации КАК ДокументКорректировка,
		|	ЗаявкаНаВозвратТоваровОтКлиентаВозвращаемыеТовары.НомерСтроки КАК НомерСтроки
		|ИЗ
		|	Документ.ЗаявкаНаВозвратТоваровОтКлиента.ВозвращаемыеТовары КАК ЗаявкаНаВозвратТоваровОтКлиентаВозвращаемыеТовары
		|ГДЕ
		|	ЗаявкаНаВозвратТоваровОтКлиентаВозвращаемыеТовары.Ссылка = &Ссылка
		|	И ЗаявкаНаВозвратТоваровОтКлиентаВозвращаемыеТовары.Отменено = ЛОЖЬ";
	
	Запрос.УстановитьПараметр("Ссылка", ДокументПродажи.Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Если НЕ ЗначениеЗаполнено(Выборка.ДокументКорректировка) Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	Возврат Истина;
	
КонецФункции// } #wortmann

// #wortmann {
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee10d8f761b7e8
// Проверка на документ ЗаявкаНаВозвратТоваровОтКлиента и документ ВозвратТоваровОтКлиента
// Из-за изменения типового механизма возврата товаров и проведения корректировки до возврата
// необходимо отменять проверку для вышеукзанных документов при условии уже проведенной корректировки
// Галфинд_ДомнышеваКР_15_06_2023
Функция УсловиеЗаявкиНаВозвратИЛИОснованияЗаявки(ДокументПродажи)
	
	Если ((ТипЗнч(ДокументПродажи) = Тип("ДокументСсылка.ЗаявкаНаВозвратТоваровОтКлиента")  
		ИЛИ ТипЗнч(ДокументПродажи) = Тип("ДокументОбъект.ЗаявкаНаВозвратТоваровОтКлиента"))
		И КорректировкиЗаполненыВсе(ДокументПродажи))
		ИЛИ((ТипЗнч(ДокументПродажи) = Тип("ДокументСсылка.ВозвратТоваровОтКлиента") 
		ИЛИ ТипЗнч(ДокументПродажи) = Тип("ДокументОбъект.ВозвратТоваровОтКлиента"))
		И ЗначениеЗаполнено(ДокументПродажи.ЗаявкаНаВозвратТоваровОтКлиента)) Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
			
КонецФункции// } #wortmann 
#КонецОбласти