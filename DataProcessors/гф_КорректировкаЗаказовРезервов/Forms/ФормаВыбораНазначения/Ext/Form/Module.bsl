﻿#Область ОбработчикиСобытийФормы 

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЗаполнитьОтборы();
	ЗаполнитьСписокНазначений();
	АвтоЗаголовок = Ложь;
	Заголовок = "Выбор нового назначения";
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	УправлениеВидимостью();
КонецПроцедуры

&НаКлиенте
Процедура УправлениеВидимостью()
	Элементы.отборВариантКомплектации.Видимость = флРезервыВКоробах;
	Элементы.отборНоменклатура.Видимость = Не флРезервыВКоробах;
	Элементы.отборХарактеристика.Видимость = Не флРезервыВКоробах;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьОтборы()
	мЗаказКлиента = Параметры["мЗаказКлиента"];
	отборОрганизация = мЗаказКлиента.Организация;
	отборСклад = мЗаказКлиента.Склад;
	отборВариантКомплектации = Параметры["ВариантКомплектации"];
	отборНоменклатура = Параметры["Номенклатура"];
	отборХарактеристика = Параметры["Характеристика"];
	флРезервыВКоробах = Параметры["РезервыВКоробах"];
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокНазначений()
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	// 1. найдем все заказы по отборам
	Если флРезервыВКоробах Тогда
		Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
		               |	ЗаказКлиентагф_ТоварыВКоробах.Ссылка КАК Заказ
		               |ПОМЕСТИТЬ втЗаказы
		               |ИЗ
		               |	Документ.ЗаказКлиента.гф_ТоварыВКоробах КАК ЗаказКлиентагф_ТоварыВКоробах
		               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК ЗаказКлиента
		               |		ПО (ЗаказКлиента.Ссылка = ЗаказКлиентагф_ТоварыВКоробах.Ссылка)
		               |ГДЕ
		               |	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации = &ВариантКомплектации
		               |	И ЗаказКлиента.Проведен
		               |	И ЗаказКлиента.Организация = &Организация
		               |	И ЗаказКлиента.Склад = &Склад
		               |	И ЗаказКлиента.Статус <> ЗНАЧЕНИЕ(Перечисление.СтатусыЗаказовКлиентов.Закрыт)
		               |	И ЗаказКлиента.Дата >= &ДатаНачала
		               |	И ЗаказКлиента.Дата <= &ДатаОкончания";
		Если Не ЗначениеЗаполнено(отборВариантКомплектации) Тогда
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации = &ВариантКомплектации",
				"ИСТИНА");
		КонецЕсли;
	Иначе
		Запрос.Текст = "ВЫБРАТЬ
		               |	ЗаказКлиентаТовары.Ссылка КАК Заказ
		               |ПОМЕСТИТЬ втЗаказы
		               |ИЗ
		               |	Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
		               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК ЗаказКлиента
		               |		ПО (ЗаказКлиента.Ссылка = ЗаказКлиентаТовары.Ссылка)
		               |ГДЕ
		               |	ЗаказКлиентаТовары.Номенклатура = &Номенклатура
		               |	И ЗаказКлиентаТовары.Характеристика = &Характеристика
		               |	И ЗаказКлиента.Проведен
		               |	И ЗаказКлиента.Организация = &Организация
		               |	И ЗаказКлиента.Склад = &Склад
		               |	И ЗаказКлиента.Статус <> ЗНАЧЕНИЕ(Перечисление.СтатусыЗаказовКлиентов.Закрыт)
		               |	И ЗаказКлиента.Дата >= &ДатаНачала
		               |	И ЗаказКлиента.Дата <= &ДатаОкончания";
		Если Не ЗначениеЗаполнено(отборНоменклатура) Тогда
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "ЗаказКлиентаТовары.Номенклатура = &Номенклатура", "ИСТИНА");
		КонецЕсли;
		Если Не ЗначениеЗаполнено(отборХарактеристика) Тогда
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "ЗаказКлиентаТовары.Характеристика = &Характеристика", "ИСТИНА");
		КонецЕсли;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(отборПериод.ДатаНачала) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ЗаказКлиента.Дата >= &ДатаНачала", "ИСТИНА");
	КонецЕсли;
	Если Не ЗначениеЗаполнено(отборПериод.ДатаОкончания) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ЗаказКлиента.Дата <= &ДатаОкончания", "ИСТИНА");
	КонецЕсли;
	Запрос.УстановитьПараметр("Организация", отборОрганизация);
	Запрос.УстановитьПараметр("Склад", отборСклад);
	Запрос.УстановитьПараметр("ВариантКомплектации", отборВариантКомплектации);
	Запрос.УстановитьПараметр("Номенклатура", отборНоменклатура);
	Запрос.УстановитьПараметр("Характеристика", отборХарактеристика);
	Запрос.УстановитьПараметр("ДатаНачала", отборПериод.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", КонецДня(отборПериод.ДатаОкончания));
	Запрос.Выполнить();
	// втЗаказы
	
	// 2. получим таблицу с товарами из заказов
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЗаказКлиентаТовары.Ссылка КАК Заказ,
	               |	ЗаказКлиентаТовары.Номенклатура КАК Номенклатура,
	               |	ЗаказКлиентаТовары.Характеристика КАК Характеристика,
	               |	СУММА(ЗаказКлиентаТовары.Количество) КАК Количество
	               |ПОМЕСТИТЬ втЗаказыТовары
	               |ИЗ
	               |	Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
	               |ГДЕ
	               |	ЗаказКлиентаТовары.Ссылка В
	               |			(ВЫБРАТЬ
	               |				втЗаказы.Заказ
	               |			ИЗ
	               |				втЗаказы КАК втЗаказы)
	               |	И ЗаказКлиентаТовары.Номенклатура = &Номенклатура
	               |	И ЗаказКлиентаТовары.Характеристика = &Характеристика
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ЗаказКлиентаТовары.Ссылка,
	               |	ЗаказКлиентаТовары.Номенклатура,
	               |	ЗаказКлиентаТовары.Характеристика
	               |
	               |ИМЕЮЩИЕ
	               |	СУММА(ЗаказКлиентаТовары.Количество) <> 0";
		Если Не ЗначениеЗаполнено(отборНоменклатура) Тогда
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "ЗаказКлиентаТовары.Номенклатура = &Номенклатура", "ИСТИНА");
		КонецЕсли;
		Если Не ЗначениеЗаполнено(отборХарактеристика) Тогда
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "ЗаказКлиентаТовары.Характеристика = &Характеристика", "ИСТИНА");
		КонецЕсли;
	Запрос.Выполнить();
	// втЗаказыТовары
	
	// 3. найдем остатки номенклатуры
	ЗаполнитьСписокНоменклатуры();
	ТаблицаОстатки = ПолучитьТаблицуОстатков(СписокНоменклатуры, мЗаказКлиента, Истина,
		"Склад, Номенклатура, Характеристика, Назначение", "Доступно");
	МассивУдалитьСтроки = Новый Массив;
	Для Каждого СтрокаТЗ Из ТаблицаОстатки Цикл
		Если Не ЗначениеЗаполнено(СтрокаТЗ["Назначение"]) Тогда
			МассивУдалитьСтроки.Добавить(СтрокаТЗ);
		КонецЕсли;
	КонецЦикла;
	Для Каждого УдалитьСтроку Из МассивУдалитьСтроки Цикл
		ТаблицаОстатки.Удалить(УдалитьСтроку);
	КонецЦикла;
	// ТаблицаОстатки
	Запрос.Текст = "ВЫБРАТЬ
	               |	т.Номенклатура КАК Номенклатура,
	               |	т.Характеристика КАК Характеристика,
	               |	т.Назначение КАК Назначение,
	               |	т.Доступно КАК Доступно
	               |ПОМЕСТИТЬ втОстатки
	               |ИЗ
	               |	&ТаблицаОстатки КАК т";
	Запрос.УстановитьПараметр("ТаблицаОстатки", ТаблицаОстатки);
	Запрос.Выполнить();
	// втОстатки
	
	// 4. найдем "не обеспеченные" остатки номенклатуры
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЗаказКлиентаТовары.Заказ КАК Заказ,
	               |	ЗаказКлиентаТовары.Номенклатура КАК Номенклатура,
	               |	ЗаказКлиентаТовары.Характеристика КАК Характеристика,
	               |	ЗаказКлиентаТовары.Количество КАК Количество,
	               |	ЕСТЬNULL(втОстатки.Доступно, 0) КАК Доступно
	               |ПОМЕСТИТЬ втНеОбеспеченныеЗаказы
	               |ИЗ
	               |	втЗаказыТовары КАК ЗаказКлиентаТовары
	               |		ЛЕВОЕ СОЕДИНЕНИЕ втОстатки КАК втОстатки
	               |		ПО ЗаказКлиентаТовары.Заказ = втОстатки.Назначение.Заказ
	               |			И ЗаказКлиентаТовары.Номенклатура = втОстатки.Номенклатура
	               |			И ЗаказКлиентаТовары.Характеристика = втОстатки.Характеристика
	               |ГДЕ
	               |	ВЫБОР
	               |			КОГДА ЗаказКлиентаТовары.Количество > ЕСТЬNULL(втОстатки.Доступно, 0)
	               |				ТОГДА ИСТИНА
	               |			ИНАЧЕ ЛОЖЬ
	               |		КОНЕЦ";
	Запрос.Выполнить();
	// втНеОбеспеченныеЗаказы
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	МАКСИМУМ(Назначения.Ссылка) КАК Назначение,
	               |	ЗаказыКлиентов.Заказ КАК Заказ
	               |ИЗ
	               |	Справочник.Назначения КАК Назначения
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ втНеОбеспеченныеЗаказы КАК ЗаказыКлиентов
	               |		ПО (ЗаказыКлиентов.Заказ = Назначения.Заказ)
	               |			И (НЕ ЗаказыКлиентов.Заказ = &ТекущийЗаказ)
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ЗаказыКлиентов.Заказ";
	Запрос.УстановитьПараметр("ТекущийЗаказ", мЗаказКлиента);
	Результат = Запрос.Выполнить();
	СписокНазначений.Загрузить(Результат.Выгрузить());
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокНоменклатуры()
	
	СписокНоменклатуры.Очистить();
	
	Если флРезервыВКоробах Тогда
		Для Каждого СтрокаКомплектации Из отборВариантКомплектации.Товары Цикл
			СписокНоменклатуры.Добавить(СтрокаКомплектации.Номенклатура);
		КонецЦикла;
	Иначе
		СписокНоменклатуры.Добавить(отборНоменклатура);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура отборПериодПриИзменении(Элемент)
	ЗаполнитьСписокНазначений();
КонецПроцедуры

&НаКлиенте
Процедура Выбрать(Команда)
	ТД = Элементы.СписокНазначений.ТекущиеДанные;
	Если ТД <> Неопределено Тогда
		Закрыть(ТД.Назначение);
	Иначе
		Закрыть(Неопределено);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СписокНазначенийВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ТД = Элементы.СписокНазначений.ТекущиеДанные;
	Если ТД <> Неопределено Тогда
		Закрыть(ТД.Назначение);
	Иначе
		Закрыть(Неопределено);
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьТаблицуОстатков(СписокНоменклатуры, мЗаказКлиента, парамОбособленныеТовары, ПоляГруппировки,
			ПоляСуммирования)
	
	СхемаКомпоновкиДанных = Отчеты.ОстаткиИДоступностьТоваров.ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанных");
	
	НастройкиОтчета = СхемаКомпоновкиДанных.НастройкиПоУмолчанию;
	
	КомпоновщикНастроек = Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаКомпоновкиДанных));
	КомпоновщикНастроек.ЗагрузитьНастройки(НастройкиОтчета);
	
	КомпоновщикНастроек.Настройки.Структура.Очистить();
	
    ГруппировкаДетальныеПоля = КомпоновщикНастроек.Настройки.Структура.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
    ГруппировкаДетальныеПоля.Использование = Истина;
    ГруппировкаДетальныеПоля.Выбор.Элементы.Добавить(Тип("АвтоВыбранноеПолеКомпоновкиДанных"));
	
	ПолеПараметрыДанных	= Новый ПолеКомпоновкиДанных("ПараметрыДанных");
	ПолеСистемныеПоля	= Новый ПолеКомпоновкиДанных("СистемныеПоля"); 
    Для Каждого ПолеВыбора Из КомпоновщикНастроек.Настройки.ДоступныеПоляВыбора.Элементы Цикл
		ВыбранноеПоле = КомпоновщикНастроек.Настройки.Выбор.Элементы.Добавить(Тип("ВыбранноеПолеКомпоновкиДанных"));
		ВыбранноеПоле.Использование	= Не (ПолеВыбора.Поле = ПолеПараметрыДанных ИЛИ ПолеВыбора.Поле = ПолеСистемныеПоля);
		ВыбранноеПоле.Поле			= ПолеВыбора.Поле;
	КонецЦикла;	 
	
	ПараметрОбособленныеТовары = КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти(
		"ПоказатьОбособленныеТовары");
	Если ПараметрОбособленныеТовары <> Неопределено Тогда
		ПараметрОбособленныеТовары.Значение = парамОбособленныеТовары;
	КонецЕсли;
	
	ЭлементОтбора = КомпоновщикНастроек.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение		= Новый ПолеКомпоновкиДанных("Номенклатура");
	ЭлементОтбора.ВидСравнения		= ВидСравненияКомпоновкиДанных.ВСписке;
	ЭлементОтбора.Использование		= Истина;
	ЭлементОтбора.ПравоеЗначение	= СписокНоменклатуры;
	
	ЭлементОтбора = КомпоновщикНастроек.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение		= Новый ПолеКомпоновкиДанных("Склад");
	ЭлементОтбора.ВидСравнения		= ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.Использование		= Истина;
	ЭлементОтбора.ПравоеЗначение	= мЗаказКлиента.Склад;
	
	СегментыСервер.ВключитьОтборПоСегментуНоменклатурыВСКД(КомпоновщикНастроек);

	ТекстЗапроса = СхемаКомпоновкиДанных.НаборыДанных.Основной.Запрос;

	ТекстЗапросаВесУпаковки = Справочники.УпаковкиЕдиницыИзмерения.ТекстЗапросаВесУпаковки(
		"Таблица.Номенклатура.ЕдиницаИзмерения", "Таблица.Номенклатура");
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ТекстЗапросаВесНоменклатуры", ТекстЗапросаВесУпаковки);
		
	ТекстЗапросаОбъемУпаковки = Справочники.УпаковкиЕдиницыИзмерения.ТекстЗапросаОбъемУпаковки(
		"Таблица.Номенклатура.ЕдиницаИзмерения", "Таблица.Номенклатура");
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ТекстЗапросаОбъемНоменклатуры", ТекстЗапросаОбъемУпаковки);

	СхемаКомпоновкиДанных.НаборыДанных.Основной.Запрос = ТекстЗапроса;
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных();    
	НастройкиОтчета = КомпоновщикНастроек.ПолучитьНастройки();
	ТипГенератора = Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений");
	МакетКомпоновкиДанных = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиОтчета, , , ТипГенератора);
    
    ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
    ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновкиДанных);
    
    Таблица = Новый ТаблицаЗначений;
    
    ПроцессорВыводаРезультатаКомпоновкиДанных = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
    ПроцессорВыводаРезультатаКомпоновкиДанных.УстановитьОбъект(Таблица);
    ПроцессорВыводаРезультатаКомпоновкиДанных.Вывести(ПроцессорКомпоновкиДанных);
	
	МассивУдалитьСтроки = Новый Массив;
	Для Каждого СтрокаТЗ Из Таблица Цикл
		Если СтрокаТЗ["ТипЗаписи"] <> "Сейчас" Тогда
			МассивУдалитьСтроки.Добавить(СтрокаТЗ);
			Продолжить;
		КонецЕсли;
	КонецЦикла;
	Для Каждого УдалитьСтроку Из МассивУдалитьСтроки Цикл
		Таблица.Удалить(УдалитьСтроку);
	КонецЦикла;
	ТаблицаОстатки = Таблица.Скопировать();
	ТаблицаОстатки.Свернуть(ПоляГруппировки, ПоляСуммирования);
	
	Возврат ТаблицаОстатки;
	
КонецФункции

#КонецОбласти
