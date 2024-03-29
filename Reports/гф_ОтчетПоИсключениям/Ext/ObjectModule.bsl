﻿Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	
	// ++
	ПараметрыДанных = Настройки.ПараметрыДанных;
	НайденныйПараметр = ПараметрыДанных.Элементы.Найти("ДатаНачала");
	Если ТипЗнч(НайденныйПараметр.Значение) = Тип("Дата") Тогда
	//	Запрос.УстановитьПараметр("ДатаНачала", НайденныйПараметр.Значение);
	Иначе
	//	Запрос.УстановитьПараметр("ДатаНачала", НайденныйПараметр.Значение.Дата);
	КонецЕсли;
	
	НайденныйПараметр = ПараметрыДанных.Элементы.Найти("ДатаОкончания");
	Если ТипЗнч(НайденныйПараметр.Значение) = Тип("Дата") Тогда
	//	Запрос.УстановитьПараметр("ДатаНачала", НайденныйПараметр.Значение);
	Иначе
	//	Запрос.УстановитьПараметр("ДатаОкончания", НайденныйПараметр.Значение.Дата);
	КонецЕсли;
	
	Если Настройки.ДополнительныеСвойства.ВариантНаименование = "Отчет по исключениям"
		ИЛИ Настройки.ДополнительныеСвойства.ВариантНаименование = "Исключения по регистратору"
		ИЛИ Настройки.ДополнительныеСвойства.ВариантНаименование = "Исключения по видам блокировок"
		Тогда
		СхемаКомпоновкиДанных.НаборыДанных.НаборДанных1.Запрос = СтрЗаменить(
			СхемаКомпоновкиДанных.НаборыДанных.НаборДанных1.Запрос,
			"И гф_ПричиныБлокировок.ВидБлокировки В(&ПросрочкаБолее30Дней)",
			"И ИСТИНА");
		СхемаКомпоновкиДанных.НаборыДанных.НаборДанных1.Запрос = СтрЗаменить(
			СхемаКомпоновкиДанных.НаборыДанных.НаборДанных1.Запрос,
			"И НЕ гф_ПричиныБлокировок.ВидБлокировки В(&ПросрочкаБолее30Дней)",
			"И ЛОЖЬ");
	Иначе
		НайденныйПараметр = ПараметрыДанных.Элементы.Найти("ПросрочкаБолее30Дней");
		Если НайденныйПараметр.Значение = Неопределено Тогда
			ПросрочкаБолее30Дней = Новый СписокЗначений;
			ПросрочкаБолее30Дней.Добавить(Справочники.гф_ВидыБлокировок.ПустаяСсылка());
			Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ПросрочкаБолее30Дней", ПросрочкаБолее30Дней);
		ИначеЕсли ТипЗнч(НайденныйПараметр.Значение) = Тип("СписокЗначений")
			И НайденныйПараметр.Значение.Количество() = 0 Тогда
			ПросрочкаБолее30Дней = Новый СписокЗначений;
			ПросрочкаБолее30Дней.Добавить(Справочники.гф_ВидыБлокировок.ПустаяСсылка());
			Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("ПросрочкаБолее30Дней", ПросрочкаБолее30Дней);
		КонецЕсли;
	КонецЕсли;
		
	КомпоновщикНастроек.ЗагрузитьНастройки(Настройки);
	// --
	
	ПолучитьДанныеНаОснованииСКД(СхемаКомпоновкиДанных, Настройки, ДокументРезультат, ,ДанныеРасшифровки);
	
	Если Настройки.ДополнительныеСвойства.ВариантНаименование = "Просрочка более 30 дней" Тогда
		ОбъединитьЯчейкиВТабличномДокументе(ДокументРезультат, "#", 0);
	Иначе
		ОбъединитьЯчейкиВТабличномДокументе(ДокументРезультат, "#");
	КонецЕсли;
	
КонецПроцедуры

// Заполняет переданный объект на основани СКД
//
// Параметры
//
//  СКД – собствеено настройки СКД
//
//  ОбъектДляЗагрузки – объект в который выгружаются данные, таблица значений, дерево значений, табличный документ
//
//  ИсполняемыеНастройки – Пользовательские настройки СКД если не указаны будут использованы настроки СКД по умолчанию
//
//  СтруктураПараметров - Структура – Передаваемые для СКД параметры
//
//  краткий лекбез, поправлю позже
//
Процедура ПолучитьДанныеНаОснованииСКД(СКД, ИсполняемыеНастройки = Неопределено, ОбъектДляЗагрузки, СтруктураПараметров = Неопределено, РасшифровкаСКД = Неопределено, МакетКомпоновки = Неопределено, ВнешниеНаборыДанных = Неопределено) Экспорт

    КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;

    Если ТипЗнч(ОбъектДляЗагрузки) = Тип("ТабличныйДокумент") Тогда
        ТипГенератора = Тип("ГенераторМакетаКомпоновкиДанных");
    Иначе
        ТипГенератора = Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений");
    КонецЕсли;

    Если ИсполняемыеНастройки = Неопределено Тогда
        ИсполняемыеНастройки = СКД.НастройкиПоУмолчанию;
    КонецЕсли;

    Если СтруктураПараметров <> Неопределено Тогда
        КоллекцияЗначенийПараметров = ИсполняемыеНастройки.ПараметрыДанных.Элементы;
        Для каждого Параметр Из СтруктураПараметров Цикл
            НайденноеЗначениеПараметра = КоллекцияЗначенийПараметров.Найти(Параметр.Ключ);
            Если НайденноеЗначениеПараметра <> Неопределено Тогда
                НайденноеЗначениеПараметра.Использование = Истина;
                НайденноеЗначениеПараметра.Значение = Параметр.Значение;
            КонецЕсли;
        КонецЦикла;
    КонецЕсли;
	
	Данные = ПолучитьБлокировкиКонтрагентовПоОрганизациям(ИсполняемыеНастройки);
	
	ВнешниеНаборыДанных = Новый Структура;
	ВнешниеНаборыДанных.Вставить("ТаблицаБлокировок", Данные);
	
    МакетКомпоновкиСКД = КомпоновщикМакета.Выполнить(СКД, ИсполняемыеНастройки, РасшифровкаСКД, МакетКомпоновки, ТипГенератора);
    ПроцессорКомпановки = Новый ПроцессорКомпоновкиДанных;
    ПроцессорКомпановки.Инициализировать(МакетКомпоновкиСКД, ВнешниеНаборыДанных, РасшифровкаСКД, Истина);
    Если ТипЗнч(ОбъектДляЗагрузки) = Тип("ТабличныйДокумент") Тогда
        ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
        ПроцессорВывода.УстановитьДокумент(ОбъектДляЗагрузки);
    Иначе
        ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
        ПроцессорВывода.УстановитьОбъект(ОбъектДляЗагрузки);
    КонецЕсли;

    ПроцессорВывода.ОтображатьПроцентВывода = Истина;
    ПроцессорВывода.Вывести(ПроцессорКомпановки, Истина);

КонецПроцедуры // ПолучитьДанныеНаОснованииСКД()

Процедура ОбъединитьЯчейкиВТабличномДокументе(ТабличныйДокумент, МаркерОбъединения, СмещениеВПраво = 1) Экспорт
	// Находит ячейки, содержащие в тексте МаркерОбъединения
	// Объединяет ячейки, располагающиеся рядом, содержащие одинаковый текст и маркер объединения 

	ОбъединяемыеЯчейки = НайтиОбластиТабличногоДокументаПоВхождениюПодстроки(ТабличныйДокумент, МаркерОбъединения);
	
	ОбъединяемыеОбласти = ОбъединяемыеЯчейки.Скопировать();
	ОбъединяемыеОбласти.Свернуть("Текст, Верх");
	ОбъединяемыеОбласти.Колонки.Добавить("Диапазон");

	Для Каждого Строка из ОбъединяемыеОбласти Цикл
		Отбор = Новый Структура("Текст,Верх", Строка.Текст, Строка.Верх);
		Лево = 0;
		Право = 0;
		НайденныеЯчейки = ОбъединяемыеЯчейки.НайтиСтроки(Отбор);
		Для Каждого Ячейка Из НайденныеЯчейки Цикл
			Если Лево = 0 Тогда
				Лево = Ячейка.Область.Лево;
			Иначе
				Лево = Мин(Лево, Ячейка.Область.Лево);
			КонецЕсли;
			Если Право = 0 Тогда
				Право = Ячейка.Область.Право;
			Иначе
				Право = Макс(Право, Ячейка.Область.Право);
			КонецЕсли;
		КонецЦикла;
		Строка.Диапазон = Новый Структура("Текст,Верх,Лево,Низ,Право", Строка.Текст, Строка.Верх, Лево, Строка.Верх, Право);
	КонецЦикла;

	Для Каждого Строка Из ОбъединяемыеОбласти Цикл
		Диапазон = Строка.Диапазон;
		Область = ТабличныйДокумент.Область(Диапазон.Верх, Диапазон.Лево, Диапазон.Низ, Диапазон.Право+СмещениеВПраво);
		Область.Объединить();
		Область.Текст = Строка.Текст;
		// Удалим маркер объединения из текст ячейки
		Область.Текст = СтрЗаменить(Область.Текст, МаркерОбъединения, "");
		Область.ВертикальноеПоложение = ВертикальноеПоложение.Центр;
		Область.ГоризонтальноеПоложение = ГоризонтальноеПоложение.Центр;
	КонецЦикла;
	
КонецПроцедуры

Функция НайтиОбластиТабличногоДокументаПоВхождениюПодстроки(ТабличныйДокумент, ПодстрокаПоиска) Экспорт
	
	НайденныеОбласти = Новый ТаблицаЗначений;
	НайденныеОбласти.Колонки.Добавить("Область");
	НайденныеОбласти.Колонки.Добавить("Текст");
	НайденныеОбласти.Колонки.Добавить("Верх");
	НайденныеОбласти.Колонки.Добавить("Лево");
	
	НайденнаяОбласть = ТабличныйДокумент.НайтиТекст(ПодстрокаПоиска);
	
	Пока НЕ НайденнаяОбласть = Неопределено Цикл
		
		НоваяСтрока = НайденныеОбласти.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, НайденнаяОбласть);
		НоваяСтрока.Область = НайденнаяОбласть;
		
		НайденнаяОбласть = ТабличныйДокумент.НайтиТекст(ПодстрокаПоиска, НайденнаяОбласть);
		
	КонецЦикла;
	
	Возврат НайденныеОбласти;
	
КонецФункции

Функция СведенияОВнешнейОбработке() Экспорт
	
	ИмяОтчета = ЭтотОбъект.Метаданные().Имя; 
    Синоним = ЭтотОбъект.Метаданные().Синоним; 
    РегистрационныеДанные = Новый Структура;
    РегистрационныеДанные.Вставить("Вид",ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительныйОтчет());
	РегистрационныеДанные.Вставить("Наименование", Синоним);
    РегистрационныеДанные.Вставить("Версия", "1.0");
    РегистрационныеДанные.Вставить("БезопасныйРежим", Ложь);
    РегистрационныеДанные.Вставить("Информация", "Отчет "+Синоним);
    
    ТаблицаКоманд = ПолучитьТаблицуКоманд();
    
    // Добавим команду в таблицу
    ДобавитьКоманду(ТаблицаКоманд, Синоним, "СформироватьОтчет" , "ОткрытиеФормы", Истина, );
        
    // Сохраним таблицу команд в параметры регистрации обработки
    РегистрационныеДанные.Вставить("Команды", ТаблицаКоманд);
    
    Возврат РегистрационныеДанные;
	
КонецФункции

Функция ПолучитьТаблицуКоманд()
    
    // Создадим пустую таблицу команд и колонки в ней
    Команды = Новый ТаблицаЗначений;

    // Как будет выглядеть описание печатной формы для пользователя
    Команды.Колонки.Добавить("Представление", Новый ОписаниеТипов("Строка")); 

    // Имя нашего макета, что бы могли отличить вызванную команду в обработке печати
    Команды.Колонки.Добавить("Идентификатор", Новый ОписаниеТипов("Строка"));

    // Тут задается, как должна вызваться команда обработки
    // Возможные варианты:
    // - ОткрытиеФормы - в этом случае в колонке идентификатор должно быть указано имя формы, которое должна будет открыть система
    // - ВызовКлиентскогоМетода - вызвать клиентскую экспортную процедуру из модуля формы обработки
    // - ВызовСерверногоМетода - вызвать серверную экспортную процедуру из модуля объекта обработки
    Команды.Колонки.Добавить("Использование", Новый ОписаниеТипов("Строка"));

    // Следующий параметр указывает, необходимо ли показывать оповещение при начале и завершению работы обработки. Не имеет смысла при открытии формы
    Команды.Колонки.Добавить("ПоказыватьОповещение", Новый ОписаниеТипов("Булево"));

    // Для печатной формы должен содержать строку ПечатьMXL 
    Команды.Колонки.Добавить("Модификатор", Новый ОписаниеТипов("Строка"));
    Возврат Команды;
   
КонецФункции

Процедура ДобавитьКоманду(ТаблицаКоманд, Представление, Идентификатор, Использование = "ОткрытиеФормы", ПоказыватьОповещение = Ложь, Модификатор)
    
    // Добавляем команду в таблицу команд по переданному описанию.
    // Параметры и их значения можно посмотреть в функции ПолучитьТаблицуКоманд
    НоваяКоманда = ТаблицаКоманд.Добавить();
    НоваяКоманда.Представление = Представление;
    НоваяКоманда.Идентификатор = Идентификатор;
    НоваяКоманда.Использование = Использование;
    НоваяКоманда.ПоказыватьОповещение = ПоказыватьОповещение;
    НоваяКоманда.Модификатор = Модификатор;

КонецПроцедуры

Функция ПолучитьБлокировкиКонтрагентовПоОрганизациям(Настройки)
	ПараметрыДанных = Настройки.ПараметрыДанных;

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
	               |	гф_ПричиныБлокировок.Организация.Наименование КАК Организации,
	               |	гф_ПричиныБлокировок.Контрагент КАК КонтрагентПросрочка
	               |ИЗ
	               |	РегистрСведений.гф_ПричиныБлокировок КАК гф_ПричиныБлокировок
	               |ГДЕ
	               |	гф_ПричиныБлокировок.Регистратор.Исключения
	               |	И гф_ПричиныБлокировок.Регистратор.Проведен
	               |	И НАЧАЛОПЕРИОДА(гф_ПричиныБлокировок.Период, ДЕНЬ) = НАЧАЛОПЕРИОДА(гф_ПричиныБлокировок.Регистратор.Дата, ДЕНЬ)
	               |	И НАЧАЛОПЕРИОДА(гф_ПричиныБлокировок.Период, ДЕНЬ) >= &ДатаНачала
	               |	И НАЧАЛОПЕРИОДА(гф_ПричиныБлокировок.Период, ДЕНЬ) <= &ДатаОкончания
	               |	И гф_ПричиныБлокировок.ВидБлокировки В(&ПросрочкаБолее30Дней)
	               |ИТОГИ ПО
	               |	Контрагент";
	НайденныйПараметр = ПараметрыДанных.Элементы.Найти("ДатаНачала");
	Если ТипЗнч(НайденныйПараметр.Значение) = Тип("Дата") Тогда
		Запрос.УстановитьПараметр("ДатаНачала", НайденныйПараметр.Значение);
	Иначе
		Запрос.УстановитьПараметр("ДатаНачала", НайденныйПараметр.Значение.Дата);
	КонецЕсли;
	
	НайденныйПараметр = ПараметрыДанных.Элементы.Найти("ДатаОкончания");
	Если ТипЗнч(НайденныйПараметр.Значение) = Тип("Дата") Тогда
		Запрос.УстановитьПараметр("ДатаОкончания", НайденныйПараметр.Значение);
	Иначе
		Запрос.УстановитьПараметр("ДатаОкончания", НайденныйПараметр.Значение.Дата);
	КонецЕсли;
	НайденныйПараметр = ПараметрыДанных.Элементы.Найти("ПросрочкаБолее30Дней");
	Запрос.УстановитьПараметр("ПросрочкаБолее30Дней", НайденныйПараметр.Значение);
	Результат = Запрос.Выполнить();
	Данные = Результат.Выгрузить();
	Данные.Очистить();
	ВыборкаКонтрагент = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "КонтрагентПросрочка");
	Пока ВыборкаКонтрагент.Следующий() Цикл
		нс = Данные.Добавить();
		нс.КонтрагентПросрочка = ВыборкаКонтрагент.КонтрагентПросрочка;
		нс.Организации = "";
		Выборка = ВыборкаКонтрагент.Выбрать();
		Пока Выборка.Следующий() Цикл
			Если ЗначениеЗаполнено(нс.Организации) Тогда
				нс.Организации = нс.Организации + ",";
			КонецЕсли;
			нс.Организации = нс.Организации + СокрЛП(Выборка.Организации);
		КонецЦикла;
	КонецЦикла;
	Возврат Данные;
КонецФункции