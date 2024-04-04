﻿Функция СведенияОВнешнейОбработке() Экспорт
	
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

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)  
	СтандартнаяОбработка=Ложь;
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	//ПечатьТаблицыРассчёты(ДокументРезультат);    
	ТаблицаДляСКД =	ПолучитьФинальнуюТаблицуДляСКД();

	ВнешниеНаборыДанных = Новый Структура;
	ВнешниеНаборыДанных.Вставить("Данные", ТаблицаДляСКД);
	КомпоновщикМакета 		= Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновкиДанных   = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, Настройки, ДанныеРасшифровки);

	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновкиДанных, ВнешниеНаборыДанных, ДанныеРасшифровки, Истина);

	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);

КонецПроцедуры

Функция БюджетыКВ()
	Запрос = новый Запрос(
	"ВЫБРАТЬ
	|	а.Ссылка КАК Ссылка,
	|	а.ТипЛимита КАК ТипЛимита,
	|	а.Бюджет КАК Бюджет
	|ИЗ
	|	Справочник.гф_ВидыЛимитов КАК а
	|ГДЕ
	|	а.ТипЛимита = &ТипЛимита");
	Запрос.УстановитьПараметр("ТипЛимита", Перечисления.гф_ТипыЛимитов.KV);
	Возврат Запрос.Выполнить().Выгрузить();
КонецФункции // ()

Функция ПолучитьФинальнуюТаблицуДляСКД();
	ПользовательскиеНастройки = КомпоновщикНастроек.ПользовательскиеНастройки;
	ДатаОтчета = КомпоновкаДанныхКлиентСервер.ПолучитьПараметр(ПользовательскиеНастройки, "ДатаОтчета").Значение; 
	Если ТипЗнч(ДатаОтчета) = Тип("СтандартнаяДатаНачала") Тогда
		ДатаОтчета =ДатаОтчета.Дата;
	КонецЕсли;
	
	СКД_Расчет = ПолучитьМакет("Расчеты");
	НастройкиОтчета = СКД_Расчет.НастройкиПоУмолчанию;

	КомпоновкаДанныхКлиентСервер.УстановитьПараметр(НастройкиОтчета, "ДатаОтчета", 
			ДатаОтчета, Истина);
	ДатаОтчетаГраница = Новый Граница(КонецДня(ДатаОтчета), ВидГраницы.Включая);
	КомпоновкаДанныхКлиентСервер.УстановитьПараметр(НастройкиОтчета, "ДатаОтчетаГраница", 
			ДатаОтчетаГраница, Истина);
			
	НастройкиОтчета.Отбор.Элементы.Очистить();
	
	НастройкиТекущие = КомпоновщикНастроек.ПолучитьНастройки();
	КомпоновкаДанныхКлиентСервер.СкопироватьОтборКомпоновкиДанных(СКД_Расчет, НастройкиОтчета, НастройкиТекущие);

	БюджетыКВ = БюджетыКВ();

	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных; 
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СКД_Расчет, НастройкиОтчета,,, Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных; 
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,,, Истина); 
	
	таб = новый ТаблицаЗначений;
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.ОтображатьПроцентВывода = Истина;
	ПроцессорВывода.УстановитьОбъект(таб);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	ТабДни = таб.Скопировать();
	таб.Свернуть("Организация, Бюджет, Документ, Контрагент, Сезон, Договор, СуммаЛимита", "СуммаДолга");
	
	таб.Колонки.Добавить("Доступно", новый ОписаниеТипов("Число"));
	таб.Колонки.Добавить("Использовано", новый ОписаниеТипов("Число"));
	таб.Колонки.Добавить("КВ", новый ОписаниеТипов("Число"));
	таб.Колонки.Добавить("СуммаДокумента", новый ОписаниеТипов("Число"));
	//таб.Колонки.Добавить("Обработано", новый ОписаниеТипов("Булево"));
	
	СуммыДолга = таб.ВыгрузитьКолонку("СуммаДолга");
	таб.ЗагрузитьКолонку(СуммыДолга, "СуммаДокумента");
	
	контрагенты = таб.Скопировать(, "Контрагент");
	контрагенты.Свернуть("Контрагент");
	контрагенты.Сортировать("Контрагент");
	
	БюджетыПустаяСсылка = Справочники.гф_Бюджеты.ПустаяСсылка();
	
	Для каждого строкаК Из контрагенты Цикл
		доки = таб.Скопировать(новый Структура("Контрагент", строкаК.Контрагент), "Документ, Сезон");
		доки.Свернуть("Документ, Сезон");
		Если доки.Количество() >= 1 Тогда
			доки.Колонки.Добавить("Дата");
			доки.Колонки.Добавить("Номер");
			Для каждого строкаД Из доки Цикл
				строкаД.Дата = строкаД.Документ.Дата;
				строкаД.Номер = строкаД.Документ.Номер;
			КонецЦикла;
			доки.Сортировать("Дата, Номер");
		КонецЕсли;
		
		бюджеты = таб.Скопировать(новый Структура("Контрагент", строкаК.Контрагент), "Бюджет");
		Если бюджеты.Найти(БюджетыПустаяСсылка, "Бюджет") = Неопределено Тогда
			бюджеты.Добавить().Бюджет = БюджетыПустаяСсылка;
		КонецЕсли;
		бюджеты.Свернуть("Бюджет");
		бюджеты.Колонки.Добавить("Порядок");
		Для каждого строкаБ Из бюджеты Цикл
			Если ЗначениеЗаполнено(строкаБ.Бюджет) Тогда
				строкаБ.Порядок = строкаБ.Бюджет.Порядок;
			Иначе
				строкаБ.Порядок = 999;
			КонецЕсли;
		КонецЦикла;
		бюджеты.Сортировать("Порядок");
		
		док_пре = Неопределено;
		
		// ++ Галфинд Волков 18.09.2023
		НесколькоДокументов = Ложь;
		Если доки.Количество() > 1 Тогда
			ТабСуммаДолга = Новый ТаблицаЗначений;
			ТабСуммаДолга = таб.СкопироватьКолонки();
			ТабСуммаДолга.Очистить();
			НесколькоДокументов = Истина;
		КонецЕсли;
		// -- Галфинд Волков 18.09.2023
		
		Для каждого строкаД Из доки Цикл
						
			первый_бюджет = Истина;
			СуммаДолга = 0;
			Использовано = 0;
			Для каждого строкаБ Из бюджеты Цикл
				
				нашли = таб.НайтиСтроки(новый Структура("Контрагент, Документ, Бюджет",
					строкаК.Контрагент, строкаД.Документ, строкаБ.Бюджет));
				Если нашли.Количество() = 0 Тогда
					Продолжить;
				КонецЕсли;
				
				строкаТ = нашли[0];
				
				Если первый_бюджет Тогда
					первый_бюджет = Ложь;
				Иначе
					строкаТ.СуммаДолга = СуммаДолга;
				КонецЕсли;
				
				строкаТ.Доступно = строкаТ.СуммаЛимита;
				
				Использовано = ПолучитьИспользовано(таб, строкаК.Контрагент, строкаБ.Бюджет, строкаД.Документ);
				строкаТ.Доступно = макс(строкаТ.СуммаЛимита - Использовано);
				строкаТ.Использовано = Использовано + мин(строкаТ.СуммаДолга, строкаТ.Доступно);
				
				Если ЗначениеЗаполнено(строкаТ.Бюджет) Тогда
					СуммаДолга = макс(строкаТ.СуммаДолга - строкаТ.Доступно, 0);
					строкаТ.СуммаДолга = строкаТ.СуммаДолга - СуммаДолга;
				КонецЕсли;
				
				Если не БюджетыКВ.Найти(строкаБ.Бюджет) = Неопределено Тогда
					строкаТ.КВ = строкаТ.КВ + мин(строкаТ.Использовано, строкаТ.СуммаДолга);
				КонецЕсли;
				
			КонецЦикла;
			
			док_пре = строкаД.Документ;
			
			Если СуммаДолга > 0 Тогда
				новая = таб.Добавить();
				ЗаполнитьЗначенияСвойств(новая, строкаТ, "Организация, Бюджет, Документ, Контрагент, Сезон, Договор");
				//ЗаполнитьЗначенияСвойств(новая, строкаТ);
				новая.СуммаДолга = СуммаДолга;
				новая.Бюджет = БюджетыПустаяСсылка;
			КонецЕсли;
			
		КонецЦикла;
	КонецЦикла;
	
	ТабРезультат = таб.СкопироватьКолонки("Организация, Бюджет, Контрагент, Документ, Сезон, Договор");
	ТабРезультат.Колонки.Добавить("ДатаДокумента", новый ОписаниеТипов("Дата"));
	ТабРезультат.Колонки.Добавить("ДниОтсрочки", новый ОписаниеТипов("Число"));
	ТабРезультат.Колонки.Добавить("ДниПросрочки", новый ОписаниеТипов("Число"));
	ТабРезультат.Колонки.Добавить("ДолгКлиента", новый ОписаниеТипов("Число"));
	ТабРезультат.Колонки.Добавить("СуммаЛимита", новый ОписаниеТипов("Число"));
	ТабРезультат.Колонки.Добавить("Партнер", новый ОписаниеТипов("СправочникСсылка.Партнеры"));
	ТабРезультат.Колонки.Добавить("ПартнерКод", новый ОписаниеТипов("Строка"));
	
	Для каждого Стр Из таб Цикл
		НовСтр = ТабРезультат.Добавить();
		ЗаполнитьЗначенияСвойств(НовСтр, Стр, ,"Бюджет");
		НовСтр.Партнер = Стр.Контрагент.Партнер;
		НовСтр.ПартнерКод = НовСтр.Партнер.Код;
		НовСтр.ДатаДокумента = Стр.Документ.Дата;
		СтруктураОтбора = Новый Структура("Документ", Стр.Документ);
		СтрокиДни = ТабДни.НайтиСтроки(СтруктураОтбора);
		Если СтрокиДни.Количество() > 0 Тогда
			НовСтр.ДниОтсрочки = СтрокиДни[0].ДниОтсрочки;
			НовСтр.ДниПросрочки = СтрокиДни[0].ДниПросрочки;
		КонецЕсли;
		НовСтр.ДолгКлиента = Стр.СуммаДолга;
		НовСтр.СуммаЛимита = Стр.КВ;
		Если не БюджетыКВ.Найти(Стр.Бюджет) = Неопределено Тогда
			НовСтр.Бюджет = Стр.Бюджет;
		КонецЕсли;
		
	КонецЦикла;
	Возврат ТабРезультат;
КонецФункции // ()

Функция ПолучитьИспользовано(таб, Контрагент, Бюджет, Документ)
	
	Если не ЗначениеЗаполнено(Бюджет) Тогда
		возврат 0;
	КонецЕсли;
	
	набор = таб.Скопировать(новый Структура("Контрагент, Бюджет", Контрагент, Бюджет));
	нашли = набор.Найти(Документ, "Документ");
	а = набор.Индекс(нашли);
	Если а = 0 Тогда
		возврат 0;
	Иначе
		возврат набор[а-1].Использовано;
	КонецЕсли;
	
КонецФункции // ()
