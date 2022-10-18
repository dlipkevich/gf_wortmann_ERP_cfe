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