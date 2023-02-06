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
	ПечатьТаблицыРассчёты(ДокументРезультат);    
	ПечатьТаблицыПоСтатьеОборотов(ДокументРезультат); 
	ПечатьТаблицыЗапланированоНаДатуОтчета(ДокументРезультат);  
	ПечатьТаблицыИтоговыйРезультат (ДокументРезультат, ПланНаДату) ;

КонецПроцедуры

Процедура ПолучитьТаблицуРассчёты(ДокументРезультат)
	
	Данные.Очистить();
	Итоги.Очистить(); 
	ДокументРезультат.Очистить();
	Параметры = КомпоновщикНастроек.Настройки.ПараметрыДанных;
	Параметры.УстановитьЗначениеПараметра("ДатаОкончания", КонецДня(ДатаОкончания));  
	Для Каждого ЭлементБазовый Из КомпоновщикНастроек.Настройки.Отбор.Элементы Цикл
		Если ЭлементБазовый.Представление = "Организация" Тогда
			ЭлементБазовый.ПравоеЗначение = Организации;
			ЭлементБазовый.Использование=Истина;
			Прервать;
		КонецЕсли;                                                 
	КонецЦикла;

	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных; 
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, КомпоновщикНастроек.ПолучитьНастройки(),,, Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных; 
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,,, Истина); 
	
	таб = новый ТаблицаЗначений;
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.ОтображатьПроцентВывода = Истина;
	ПроцессорВывода.УстановитьОбъект(таб);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	таб.Колонки.Добавить("Доступно", новый ОписаниеТипов("Число"));
	таб.Колонки.Добавить("Использовано", новый ОписаниеТипов("Число"));
	
	контрагенты = таб.Скопировать(, "Контрагент");
	контрагенты.Свернуть("Контрагент");
	контрагенты.Сортировать("Контрагент");
	
	БюджетыПустаяСсылка = Справочники.гф_Бюджеты.ПустаяСсылка();
	
	Для каждого строкаК Из контрагенты Цикл
		доки = таб.Скопировать(новый Структура("Контрагент", строкаК.Контрагент), "Документ");
		доки.Свернуть("Документ");
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
		
		Для каждого строкаД Из доки Цикл
						
			первый_бюджет = Истина;
			СуммаДолга = 0;
			Использовано = 0;
			Для каждого строкаБ Из бюджеты Цикл
				
				нашли = таб.НайтиСтроки(новый Структура("Контрагент, Документ, Бюджет", строкаК.Контрагент, строкаД.Документ, строкаБ.Бюджет));
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
				
				Если строкаТ.СуммаДолга > 0 и ЗначениеЗаполнено(строкаБ.Бюджет) Тогда
					Если док_пре = Неопределено Тогда
						строкаТ.Использовано = мин(строкаТ.СуммаДолга, строкаТ.СуммаЛимита);
					Иначе
						суммы = таб.Скопировать(новый Структура("Контрагент, Документ, Бюджет", строкаК.Контрагент, док_пре, строкаБ.Бюджет));
						Если суммы.Количество() > 0 Тогда
							Использовано = суммы[0].Использовано;
						Иначе
							Использовано = 0;
						КонецЕсли;
						строкаТ.Доступно = макс(строкаТ.СуммаЛимита - Использовано);
						строкаТ.Использовано = Использовано + мин(строкаТ.СуммаДолга, строкаТ.Доступно);
					КонецЕсли;
				КонецЕсли;
				
				Если ЗначениеЗаполнено(строкаТ.Бюджет) Тогда
					СуммаДолга = макс(строкаТ.СуммаДолга - строкаТ.Доступно, 0);
					строкаТ.СуммаДолга = строкаТ.СуммаДолга - СуммаДолга;
				КонецЕсли;
			КонецЦикла;
			
			док_пре = строкаД.Документ;
			Если СуммаДолга > 0 Тогда
				новая = таб.Добавить();
				ЗаполнитьЗначенияСвойств(новая, строкаТ, "Документ, Контрагент");
				новая.СуммаДолга = СуммаДолга;
				новая.Бюджет = БюджетыПустаяСсылка;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Для каждого строка Из таб Цикл
		ЗаполнитьЗначенияСвойств(Данные.Добавить(), строка);
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьСрокПлатежа(Документ)
	
	результат = Документ.Дата;
	
	запрос = новый Запрос(
	"ВЫБРАТЬ
	|	а.Объект КАК Объект,
	|	а.Свойство КАК Свойство,
	|	а.Значение КАК Значение
	|ИЗ
	|	РегистрСведений.ДополнительныеСведения КАК а
	|ГДЕ
	|	а.Объект = &Объект
	|	И а.Свойство.Имя = &Свойство");
	запрос.УстановитьПараметр("Объект", Документ);
	запрос.УстановитьПараметр("Свойство", "гф_СчетанаоплатуСрокПлатежа");
	выборка = запрос.Выполнить().Выбрать();
	Если выборка.Следующий() Тогда
		результат = выборка.Значение;
	КонецЕсли;
	
	возврат результат;
КонецФункции // ()

Процедура ПечатьТаблицыРассчёты(ДокументРезультат)
	
	ПолучитьТаблицуРассчёты(ДокументРезультат);
	ПечатьТаблицыОбороты(ДокументРезультат);
	макет = ПолучитьМакет("Макет");
	
	строкаПустая = макет.ПолучитьОбласть("строкаПустая");
	ДокументРезультат.Вывести(строкаПустая);
	
	Бюджеты = Данные.Выгрузить(, "Бюджет");
	Бюджеты.Свернуть("Бюджет");
	Если Бюджеты.Количество() > 1 Тогда
		Бюджеты.Колонки.Добавить("Порядок");
		Для каждого строка Из Бюджеты Цикл
			Если ЗначениеЗаполнено(строка.Бюджет) Тогда
				строка.Порядок = строка.Бюджет.Порядок;
			Иначе
				строка.Порядок = 999;
			КонецЕсли;
		КонецЦикла;
		Бюджеты.Сортировать("Порядок");
	КонецЕсли;
	
	
	ВыборкаДок = Данные.Выгрузить(, "Контрагент, Документ, СуммаДолга");
	ВыборкаДок.Свернуть("Контрагент, Документ", "СуммаДолга");
	ВыборкаДок.Колонки.Добавить("Дни", новый ОписаниеТипов("Число"));
	ВыборкаДок.Колонки.Добавить("Отсрочка", новый ОписаниеТипов("Число"));
	ВыборкаДок.Индексы.Добавить("Контрагент, Документ");
	
	Для каждого строка Из ВыборкаДок Цикл  
		Если Значениезаполнено(строка.Документ) Тогда
		СрокПлатежа = ПолучитьСрокПлатежа(строка.Документ);
		строка.Отсрочка = макс(окр((СрокПлатежа - НачалоДня(строка.Документ.Дата)) / 3600 / 24, 0), 0);
		строка.Дни = макс(окр((ДатаОкончания - СрокПлатежа) / 3600 / 24, 0), 0); 
		КонецЕсли;
	КонецЦикла;
	
	
	Суммы = новый Структура;
	//Если ЛимитыПоБюджетам Тогда
		Суммы.Вставить("с1", "Сумма лимитов на дату документа");
	//КонецЕсли;
	//Если ДоступноПоБюджетам Тогда
		Суммы.Вставить("с2", "Доступно");
	//КонецЕсли;
	//Если ИспользованоПоБюджетам Тогда
		Суммы.Вставить("с3", "Использовано");
	//КонецЕсли;
	
	// заголовок
	ЗаголовокТаблица2(ДокументРезультат, Макет, Суммы, Бюджеты);
	
	//ДокументРезультат.НачатьГруппуСтрок("Расчёты", Ложь);
	
	// таблица
	
	контрагенты = Данные.Выгрузить(, "Контрагент");
	контрагенты.Свернуть("Контрагент");
	контрагенты.Сортировать("Контрагент");
	
	Для каждого строкаК Из контрагенты Цикл
			
		СтрокаГруппаКонтрагентТаблица2(строкаК, ДокументРезультат, Макет, Суммы, Бюджеты, ВыборкаДок);
		
		//ДокументРезультат.НачатьГруппуСтрок(строкаК.Контрагент, Ложь);
		
		доки = Данные.Выгрузить(новый Структура("Контрагент", строкаК.Контрагент), "Документ");
		доки.Свернуть("Документ");
		Если доки.Количество() >= 1 Тогда
			доки.Колонки.Добавить("Дата");
			доки.Колонки.Добавить("Номер");
			Для каждого строкаД Из доки Цикл  
				Если ЗначениеЗаполнено(строкаД.Документ) Тогда
				строкаД.Дата = строкаД.Документ.Дата;
				строкаД.Номер = строкаД.Документ.Номер; 
				КонецЕсли;
			КонецЦикла;
			доки.Сортировать("Дата, Номер");
		КонецЕсли; 
	    СтрокаКонтрагентыТаблица2( строкаК.Контрагент, ДокументРезультат, Макет, Суммы, Бюджеты, ВыборкаДок)  ;   
				ДокументРезультат.НачатьГруппуСтрок(строкаК.Контрагент, Ложь);

		Для каждого строкаД Из доки Цикл   
			Если ЗначениеЗаполнено(строкаД.Документ ) Тогда
			СтрокаДокументыТаблица2(строкаД, строкаК.Контрагент, ДокументРезультат, Макет, Суммы, Бюджеты, ВыборкаДок);    
		КонецЕсли;  
		КонецЦикла;
				ДокументРезультат.ЗакончитьГруппуСтрок();

	КонецЦикла;
	
	// итоги второй таблицы
	ИтогиТаблица2(ДокументРезультат, Макет, Суммы, Бюджеты, ВыборкаДок);
	
	ДокументРезультат.Вывести(строкаПустая);
	
	ДокументРезультат.ФиксацияСверху = 3;
	ДокументРезультат.ФиксацияСлева = 2;
	//ДокументРезультат.ЗакончитьГруппуСтрок();
	
КонецПроцедуры

Процедура ЗаголовокТаблица2(ДокументРезультат, Макет, Суммы, Бюджеты)
	
	//контрагент, договор
	
	ЗаголовокЛево = макет.ПолучитьОбласть("Заголовок|Лево");
	ДокументРезультат.Вывести(ЗаголовокЛево);
	
	//сумма долга
	
	область = макет.ПолучитьОбласть("Заголовок|Интервал");
	область.Параметры.Интервал = "Сумма долга" + Символы.ПС + "Всего";
	ДокументРезультат.Присоединить(область);
	
	бюджет1 = макет.ПолучитьОбласть("Заголовок|бюджет1");
	бюджет2 = макет.ПолучитьОбласть("Заголовок|бюджет2");
	
	//Если ДолгиПоБюджетам Тогда
		ДокументРезультат.НачатьГруппуКолонок("Интервал", Ложь);
		первый = Истина;
		Для каждого строкаБ Из бюджеты Цикл
			ПараметрБюджет = ?(ЗначениеЗаполнено(строкаБ.Бюджет), строкаБ.Бюджет, "Не обеспечено бюджетом");
			Если первый Тогда
				бюджет1.Параметры.СтрокаДолга = "Сумма долга";
				бюджет1.Параметры.Бюджет = ПараметрБюджет;
				ДокументРезультат.Присоединить(бюджет1);
				первый = Ложь;
			Иначе
				бюджет2.Параметры.Бюджет = ПараметрБюджет;
				ДокументРезультат.Присоединить(бюджет2);
			КонецЕсли;
		КонецЦикла;
		ДокументРезультат.ЗакончитьГруппуКолонок();
	//КонецЕсли;
	
	//интервалы
	//ДокументРезультат.Присоединить(макет.ПолучитьОбласть("Заголовок|Отсрочка"));
	//ДокументРезультат.Присоединить(макет.ПолучитьОбласть("Заголовок|Дни"));
	
	//лимиты
	Для каждого строкаС Из суммы Цикл
		первый = Истина;
		Для каждого строкаБ Из бюджеты Цикл
			Если не ЗначениеЗаполнено(строкаБ.Бюджет) Тогда
				Продолжить;
			КонецЕсли;
			ПараметрБюджет = ?(ЗначениеЗаполнено(строкаБ.Бюджет), строкаБ.Бюджет, "Не обеспечено бюджетом");
			Если первый Тогда
				бюджет1.Параметры.СтрокаДолга = строкаС.Значение;
				бюджет1.Параметры.Бюджет = ПараметрБюджет;
				ДокументРезультат.Присоединить(бюджет1);
				первый = Ложь;
			Иначе
				бюджет2.Параметры.Бюджет = ПараметрБюджет;
				ДокументРезультат.Присоединить(бюджет2);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

Процедура СтрокаГруппаКонтрагентТаблица2(строкаК, ДокументРезультат, Макет, Суммы, Бюджеты, ВыборкаДок)

	Для каждого строкаБ Из бюджеты Цикл
		
		СуммыБюджет = Данные.Выгрузить(новый Структура("Контрагент, Бюджет", строкаК.Контрагент, строкаБ.Бюджет));
		ИтогСуммаДолга = СуммыБюджет.Итог("СуммаДолга");  
		Если ИтогСуммаДолга > 0 Тогда
			новая = итоги.Добавить();
			новая.Контрагент = строкаК.Контрагент;
			новая.Бюджет = строкаБ.Бюджет;
			новая.СуммаДолга = ИтогСуммаДолга;
		КонецЕсли;
		
		Если не ЗначениеЗаполнено(строкаБ.Бюджет) Тогда
			Продолжить;
		КонецЕсли;
		
		граница = суммыБюджет.Количество();
		Если граница > 0 Тогда
			СтрокаСуммыБюджет = суммыБюджет[граница-1];
			
			Если граница > 1 Тогда
				суммыБюджет.Колонки.Добавить("Дата");
				суммыБюджет.Колонки.Добавить("Номер");
				Для каждого строкаД Из суммыБюджет Цикл
					строкаД.Дата = строкаД.Документ.Дата;
					строкаД.Номер = строкаД.Документ.Номер;
				КонецЦикла;
				суммыБюджет.Сортировать("Дата, Номер");
			КонецЕсли;
			
			новая = итоги.Добавить();
			новая.Контрагент = строкаК.Контрагент;
			новая.Бюджет = строкаБ.Бюджет;
			новая.СуммаЛимита = СтрокаСуммыБюджет.СуммаЛимита;
			
			новая = итоги.Добавить();
			новая.Контрагент = строкаК.Контрагент;
			новая.Бюджет = строкаБ.Бюджет;
			новая.Доступно = СтрокаСуммыБюджет.Доступно;
			
			новая = итоги.Добавить();
			новая.Контрагент = строкаК.Контрагент;
			новая.Бюджет = строкаБ.Бюджет;
			новая.Использовано = СтрокаСуммыБюджет.Использовано;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры
 Процедура СтрокаКонтрагентыТаблица2( Контрагент, ДокументРезультат, Макет, Суммы, Бюджеты, ВыборкаДок)
	
	//контрагент, документ
	
	строкаДокумент = макет.ПолучитьОбласть("строкаКонтрагент|Лево");
	строкаДокументБ1 = макет.ПолучитьОбласть("строкаКонтрагент|Бюджет1");
	строкаДокументБ2 = макет.ПолучитьОбласть("строкаКонтрагент|Бюджет2");
	строкаКрай = макет.ПолучитьОбласть("строкаКонтрагент|Край");
	
	строкаДокумент.Параметры.Контрагент = Контрагент;
	ДокументРезультат.Вывести(строкаДокумент);
	
	//сумма долга
	
	суммыБюджет = Данные.Выгрузить(новый Структура("Контрагент", Контрагент));
	область = макет.ПолучитьОбласть("строкаКонтрагент|Интервал");
	область.Параметры.Сумма = суммыБюджет.Итог("СуммаДолга");
	ДокументРезультат.Присоединить(область);
	
	//Если ДолгиПоБюджетам Тогда
		перваяколонка = Истина;
		Для каждого строкаБ Из бюджеты Цикл
			
			суммыБюджет = Данные.Выгрузить(новый Структура("Контрагент, Бюджет", Контрагент, строкаБ.Бюджет));
			граница = суммыБюджет.Количество();
			
			Если перваяколонка Тогда
				макетстроки = строкаДокументБ1;
				перваяколонка = Ложь;
			Иначе
				макетстроки = строкаДокументБ2;
			КонецЕсли;
			
			Если граница = 0 Тогда
				макетстроки.Параметры.Бюджет = 0;
			Иначе
				макетстроки.Параметры.Бюджет = суммыБюджет.Итог("СуммаДолга");
			КонецЕсли;
			ДокументРезультат.Присоединить(макетстроки);
		КонецЦикла;
	//КонецЕсли;
	
	//интервалы
	
	нашли = ВыборкаДок.Скопировать(новый Структура("Контрагент", Контрагент));
	нашли = нашли[0];
	
	
	//лимиты
	
	Для каждого строкаС Из суммы Цикл
		
		перваяколонка = Истина;
		
		Для каждого строкаБ Из бюджеты Цикл
			
			Если не ЗначениеЗаполнено(строкаБ.Бюджет) Тогда
				Продолжить;
			КонецЕсли;
			
			Если не строкаС.Ключ = "с1" и не ЗначениеЗаполнено(строкаБ.Бюджет) Тогда
				Продолжить;
			КонецЕсли;
			
			суммыБюджет = Данные.Выгрузить(новый Структура("Контрагент, Бюджет", Контрагент, строкаБ.Бюджет));
			граница = суммыБюджет.Количество();
			
			Если перваяколонка Тогда
				макетстроки = строкаДокументБ1;
				перваяколонка = Ложь;
			Иначе
				макетстроки = строкаДокументБ2;
			КонецЕсли;
			
			Если граница = 0 Тогда
				макетстроки.Параметры.Бюджет = 0;
			Иначе
				Если строкаС.Ключ = "с1" Тогда
					макетстроки.Параметры.Бюджет = суммыБюджет.Итог("СуммаЛимита");
				ИначеЕсли строкаС.Ключ = "с2" Тогда
					макетстроки.Параметры.Бюджет = суммыБюджет.Итог("Доступно");
				ИначеЕсли строкаС.Ключ = "с3" Тогда
					макетстроки.Параметры.Бюджет = суммыБюджет.Итог("Использовано");
				КонецЕсли;
			КонецЕсли;
			ДокументРезультат.Присоединить(макетстроки);
		КонецЦикла;
	КонецЦикла;
	
	ДокументРезультат.Присоединить(строкаКрай);
	
КонецПроцедуры

Процедура СтрокаДокументыТаблица2(строкаД, Контрагент, ДокументРезультат, Макет, Суммы, Бюджеты, ВыборкаДок)
	
	//контрагент, документ
	
	строкаДокумент = макет.ПолучитьОбласть("строкаДокумент|Лево");
	строкаДокументБ1 = макет.ПолучитьОбласть("строкаДокумент|Бюджет1");
	строкаДокументБ2 = макет.ПолучитьОбласть("строкаДокумент|Бюджет2");
	строкаКрай = макет.ПолучитьОбласть("строкаДокумент|Край");
	
	строкаДокумент.Параметры.Контрагент = Контрагент;
	строкаДокумент.Параметры.Документ =строкаД.Документ;
	ДокументРезультат.Вывести(строкаДокумент);
	
	//сумма долга
	
	суммыБюджет = Данные.Выгрузить(новый Структура("Контрагент, Документ", Контрагент, строкаД.Документ));
	суммыБюджет.Свернуть("Контрагент, Документ", "СуммаДолга");
	область = макет.ПолучитьОбласть("строкаДокумент|Интервал");
	область.Параметры.Сумма = суммыБюджет[0].СуммаДолга;
	ДокументРезультат.Присоединить(область);
	
	//Если ДолгиПоБюджетам Тогда
		перваяколонка = Истина;
		Для каждого строкаБ Из бюджеты Цикл
			
			суммыБюджет = Данные.Выгрузить(новый Структура("Контрагент, Документ, Бюджет", Контрагент, строкаД.Документ, строкаБ.Бюджет));
			граница = суммыБюджет.Количество();
			
			Если перваяколонка Тогда
				макетстроки = строкаДокументБ1;
				перваяколонка = Ложь;
			Иначе
				макетстроки = строкаДокументБ2;
			КонецЕсли;
			
			Если граница = 0 Тогда
				макетстроки.Параметры.Бюджет = 0;
			Иначе
				суммыБюджет = суммыБюджет[0];
				макетстроки.Параметры.Бюджет = суммыБюджет.СуммаДолга;
			КонецЕсли;
			ДокументРезультат.Присоединить(макетстроки);
		КонецЦикла;
	//КонецЕсли;
	
	//интервалы
	
	нашли = ВыборкаДок.Скопировать(новый Структура("Контрагент, Документ", Контрагент, строкаД.Документ));
	нашли = нашли[0];
	
	//макетстроки = макет.ПолучитьОбласть("строкаДокумент|Отсрочка");
	//макетстроки.Параметры.Отсрочка = нашли.Отсрочка;
	//ДокументРезультат.Присоединить(макетстроки);
	//
	//макетстроки = макет.ПолучитьОбласть("строкаДокумент|Дни");
	//макетстроки.Параметры.Дни = нашли.Дни;
	//ДокументРезультат.Присоединить(макетстроки);
	
	
	//лимиты
	
	Для каждого строкаС Из суммы Цикл
		
		перваяколонка = Истина;
		
		Для каждого строкаБ Из бюджеты Цикл
			
			Если не ЗначениеЗаполнено(строкаБ.Бюджет) Тогда
				Продолжить;
			КонецЕсли;
			
			Если не строкаС.Ключ = "с1" и не ЗначениеЗаполнено(строкаБ.Бюджет) Тогда
				Продолжить;
			КонецЕсли;
			
			суммыБюджет = Данные.Выгрузить(новый Структура("Контрагент, Документ, Бюджет", Контрагент, строкаД.Документ, строкаБ.Бюджет));
			граница = суммыБюджет.Количество();
			
			Если перваяколонка Тогда
				макетстроки = строкаДокументБ1;
				перваяколонка = Ложь;
			Иначе
				макетстроки = строкаДокументБ2;
			КонецЕсли;
			
			Если граница = 0 Тогда
				макетстроки.Параметры.Бюджет = 0;
			Иначе
				суммыБюджет = суммыБюджет[0];
				Если строкаС.Ключ = "с1" Тогда
					макетстроки.Параметры.Бюджет = суммыБюджет.СуммаЛимита;
				ИначеЕсли строкаС.Ключ = "с2" Тогда
					макетстроки.Параметры.Бюджет = суммыБюджет.Доступно;
				ИначеЕсли строкаС.Ключ = "с3" Тогда
					макетстроки.Параметры.Бюджет = суммыБюджет.Использовано;
				КонецЕсли;
			КонецЕсли;
			ДокументРезультат.Присоединить(макетстроки);
		КонецЦикла;
	КонецЦикла;
	
	ДокументРезультат.Присоединить(строкаКрай);
	
КонецПроцедуры

Процедура ИтогиТаблица2(ДокументРезультат, Макет, Суммы, Бюджеты, ВыборкаДок)
	
	//контрагент, документ
	
	строкаИтог = макет.ПолучитьОбласть("строкаИтог|Лево");
	строкаИтог1 = макет.ПолучитьОбласть("строкаИтог|Бюджет1");
	строкаИтог2 = макет.ПолучитьОбласть("строкаИтог|Бюджет2");
	строкаИтогКрай = макет.ПолучитьОбласть("строкаИтог|Край");
	
	ДокументРезультат.Вывести(строкаИтог);
	
	//сумма долга
	
	ИтогиБюджетов = Итоги.Выгрузить();
	ИтогиБюджетов.Свернуть("Бюджет", "СуммаДолга, СуммаЛимита, Доступно, Использовано");
	
	область = макет.ПолучитьОбласть("строкаИтог|Интервал");
	область.Параметры.Сумма = ИтогиБюджетов.Итог("СуммаДолга");
	ДокументРезультат.Присоединить(область);
	
	//Если ДолгиПоБюджетам Тогда
		перваяколонка = Истина;
		Для каждого строкаБ Из бюджеты Цикл
			
			суммыБюджет = ИтогиБюджетов.Найти(строкаБ.Бюджет, "Бюджет");
			
			Если перваяколонка Тогда
				макетстроки = строкаИтог1;
				перваяколонка = Ложь;
			Иначе
				макетстроки = строкаИтог2;
			КонецЕсли;
			
			Если суммыБюджет = Неопределено Тогда
				макетстроки.Параметры.Бюджет = 0;
			Иначе
				макетстроки.Параметры.Бюджет = суммыБюджет.СуммаДолга;
			КонецЕсли;
			ДокументРезультат.Присоединить(макетстроки);
		КонецЦикла;
	//КонецЕсли;
	
	//интервалы
	
	//область = макет.ПолучитьОбласть("строкаИтог|Отсрочка");
	//область.Параметры.Отсрочка = 0;
	//ДокументРезультат.Присоединить(область);
	//
	//область = макет.ПолучитьОбласть("строкаИтог|Дни");
	//область.Параметры.Дни = 0;
	//ДокументРезультат.Присоединить(область);
	
	
	//лимиты
	
	Для каждого строкаС Из суммы Цикл
		
		перваяколонка = Истина;
		
		Для каждого строкаБ Из бюджеты Цикл
			Если не ЗначениеЗаполнено(строкаБ.Бюджет) Тогда
				Продолжить;
			КонецЕсли;
			
			суммыБюджет = ИтогиБюджетов.Найти(строкаБ.Бюджет, "Бюджет");
			
			Если перваяколонка Тогда
				макетстроки = строкаИтог1;
				перваяколонка = Ложь;
			Иначе
				макетстроки = строкаИтог2;
			КонецЕсли;
			
			Если суммыБюджет = Неопределено Тогда
				макетстроки.Параметры.Бюджет = 0;
			Иначе
				Если строкаС.Ключ = "с1" Тогда
					макетстроки.Параметры.Бюджет = суммыБюджет.СуммаЛимита;
				ИначеЕсли строкаС.Ключ = "с2" Тогда
					макетстроки.Параметры.Бюджет = суммыБюджет.Доступно;
				ИначеЕсли строкаС.Ключ = "с3" Тогда
					макетстроки.Параметры.Бюджет = суммыБюджет.Использовано;
				КонецЕсли;
			КонецЕсли;
			ДокументРезультат.Присоединить(макетстроки);
		КонецЦикла;
	КонецЦикла;
	
	ДокументРезультат.Присоединить(строкаИтогКрай);
	
КонецПроцедуры

Функция ПолучитьТаблицуЗапланированоНаДатуОтчета(Бюджеты)
	
	схема = ПолучитьМакет("ЗапланированоНаДатуОтчета");
	Компоновщик = новый КомпоновщикНастроекКомпоновкиДанных;
	Компоновщик.Инициализировать(новый ИсточникДоступныхНастроекКомпоновкиДанных(схема));
	Компоновщик.ЗагрузитьНастройки(схема.НастройкиПоУмолчанию);
	
	ПараметрыДанных = Компоновщик.Настройки.ПараметрыДанных;
	ПараметрыДанных.УстановитьЗначениеПараметра("ДатаОкончания", КонецДня(ДатаОкончания));
	ПараметрыДанных.УстановитьЗначениеПараметра("Бюджет", БюджетСписок);
	ПараметрыДанных.УстановитьЗначениеПараметра("НетБюджетов", БюджетСписок.Количество() = 0);
	
	Отборы = Компоновщик.Настройки.Отбор.Элементы;
	Для каждого строка Из КомпоновщикНастроек.Настройки.Отбор.Элементы Цикл
		новая = Отборы.Добавить(тип("ЭлементОтбораКомпоновкиДанных"));
		ЗаполнитьЗначенияСвойств(новая, строка);
	КонецЦикла;
		Для Каждого ЭлементБазовый Из КомпоновщикНастроек.Настройки.Отбор.Элементы Цикл
		Если ЭлементБазовый.Представление = "Организация" Тогда
			ЭлементБазовый.ПравоеЗначение = Организации;
			ЭлементБазовый.Использование=Истина;
			Прервать;
		КонецЕсли;                                                 
	КонецЦикла;

	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных; 
	МакетКомпоновки = КомпоновщикМакета.Выполнить(схема, Компоновщик.ПолучитьНастройки(),,, Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных; 
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,,, Истина); 
	
	таб = новый ТаблицаЗначений;
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.ОтображатьПроцентВывода = Истина;
	ПроцессорВывода.УстановитьОбъект(таб);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	Если БюджетСписок.Количество() = 0 Тогда
		Бюджеты = таб.Скопировать(, "Бюджет");
		Бюджеты.Свернуть("Бюджет");
	Иначе
		Бюджеты = новый ТаблицаЗначений;
		Бюджеты.Колонки.Добавить("Бюджет");
		Для каждого строка Из БюджетСписок Цикл
			Бюджеты.Добавить().Бюджет = строка.Значение;
		КонецЦикла;
	КонецЕсли;
	
	Если Бюджеты.Количество() > 1 Тогда
		
		нашли = Бюджеты.Найти(Неопределено);
		Если не нашли = Неопределено Тогда
			Бюджеты.Удалить(нашли);
		КонецЕсли;
		
		Бюджеты.Колонки.Добавить("Порядок");
		Для каждого строка Из Бюджеты Цикл
			строка.Порядок = строка.Бюджет.Порядок;
		КонецЦикла;
		Бюджеты.Сортировать("Порядок");
	КонецЕсли;
	
	Для каждого строка Из таб Цикл
		Если строка.Сумма < 0 Тогда
			Продолжить;
		КонецЕсли;
		
		нашли = Данные.НайтиСтроки(новый Структура("Контрагент, Бюджет", строка.Контрагент, строка.Бюджет));
		Для каждого строка2 Из нашли Цикл
			Если строка2.Документ.Дата >= строка.Период Тогда
				строка.Сумма = строка.Сумма - строка2.СуммаДолга;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	таб.Свернуть("Контрагент, Бюджет", "Сумма");
	таб.Индексы.Добавить("Контрагент, Бюджет");
	
	граница = таб.Количество() - 1;
	Для а=0 По граница Цикл
		строка = таб[граница-а];
		Если строка.Сумма = 0 Тогда
			таб.Удалить(строка);
		КонецЕсли;
	КонецЦикла;
	
	возврат таб;
КонецФункции
Функция ПолучитьТаблицуОборотов()
	
	схема = ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанных");
	Компоновщик = новый КомпоновщикНастроекКомпоновкиДанных;
	Компоновщик.Инициализировать(новый ИсточникДоступныхНастроекКомпоновкиДанных(схема));
	Компоновщик.ЗагрузитьНастройки(схема.НастройкиПоУмолчанию);
	
	ПараметрыДанных = Компоновщик.Настройки.ПараметрыДанных;
	ПараметрыДанных.УстановитьЗначениеПараметра("ДатаОкончания", КонецДня(ДатаОкончания));
	ПараметрыДанных.УстановитьЗначениеПараметра("Бюджет", БюджетСписок);
	ПараметрыДанных.УстановитьЗначениеПараметра("НетБюджетов", БюджетСписок.Количество() = 0);
	
	Отборы = Компоновщик.Настройки.Отбор.Элементы;
	Для каждого строка Из КомпоновщикНастроек.Настройки.Отбор.Элементы Цикл
		новая = Отборы.Добавить(тип("ЭлементОтбораКомпоновкиДанных"));
		ЗаполнитьЗначенияСвойств(новая, строка);
	КонецЦикла;
	Для Каждого ЭлементБазовый Из КомпоновщикНастроек.Настройки.Отбор.Элементы Цикл
		Если ЭлементБазовый.Представление = "Организация" Тогда
			ЭлементБазовый.ПравоеЗначение = Организации;
			ЭлементБазовый.Использование=Истина;
			Прервать;
		КонецЕсли;                                                 
	КонецЦикла;

	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных; 
	МакетКомпоновки = КомпоновщикМакета.Выполнить(схема, Компоновщик.ПолучитьНастройки(),,, Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных; 
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,,, Истина); 
	
	таб = новый ТаблицаЗначений;
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.ОтображатьПроцентВывода = Истина;
	ПроцессорВывода.УстановитьОбъект(таб);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
		
	возврат таб; 
	
КонецФункции

Функция ПечатьТаблицыЗапланированоНаДатуОтчета(ДокументРезультат)
	Перем Бюджеты;

	таб = ПолучитьТаблицуЗапланированоНаДатуОтчета(Бюджеты);
	
	макет = ПолучитьМакет("Макет");
	
	строкаПустая = макет.ПолучитьОбласть("строкаПустая");
	ДокументРезультат.Вывести(строкаПустая);
	
	макетЛево = макет.ПолучитьОбласть("ПланШапка|Лево");
	макетБюджет = макет.ПолучитьОбласть("ПланШапка|бюджет1");
	
	ДокументРезультат.Вывести(макетЛево);
	ДокументРезультат.НачатьГруппуСтрок(, Ложь);
	
	Для каждого строка Из Бюджеты Цикл
		макетБюджет.Параметры.Бюджет = строка.Бюджет;
		ДокументРезультат.Присоединить(макетБюджет);
	КонецЦикла;
	
	макетЛево = макет.ПолучитьОбласть("ПланСтрока|Лево");
	макетБюджет = макет.ПолучитьОбласть("ПланСтрока|бюджет1");
	
	Группа = таб.Скопировать(, "Контрагент");
	Группа.Свернуть("Контрагент");
	Группа.Сортировать("Контрагент");
	
	Для каждого строкаГ Из Группа Цикл
		
		макетЛево.Параметры.Контрагент = строкаГ.Контрагент;
		ДокументРезультат.Вывести(макетЛево);
		
		Для каждого строка Из Бюджеты Цикл
			нашли = таб.НайтиСтроки(новый Структура("Контрагент, Бюджет", строкаГ.Контрагент, строка.Бюджет));
			Если нашли.Количество() = 0 Тогда
				макетБюджет.Параметры.Сумма = 0;
			Иначе
				макетБюджет.Параметры.Сумма = нашли[0].Сумма;
			КонецЕсли;
			ДокументРезультат.Присоединить(макетБюджет);
		КонецЦикла;
	КонецЦикла;
	
	ДокументРезультат.ЗакончитьГруппуСтрок();
	
	макетЛево = макет.ПолучитьОбласть("ПланИтог|Лево");
	ДокументРезультат.Вывести(макетЛево);
	
	макетБюджет = макет.ПолучитьОбласть("ПланИтог|бюджет1");
	таб.Свернуть("Бюджет", "Сумма");
	Для каждого строка Из Бюджеты Цикл
		нашли = таб.Найти(строка.Бюджет, "Бюджет");
		Если нашли = Неопределено Тогда
			макетБюджет.Параметры.Сумма = 0;
		Иначе
			макетБюджет.Параметры.Сумма = нашли.Сумма;
		КонецЕсли;
		ДокументРезультат.Присоединить(макетБюджет);
	КонецЦикла;
	
	возврат таб;
КонецФункции

Процедура ПечатьТаблицыПоСтатьеОборотов(ДокументРезультат)
	
	СтатьяОборотаДляИспользованногоБюджета = "Использован";
	
	макет = ПолучитьМакет("Макет");
	строкаПустая = макет.ПолучитьОбласть("строкаПустая");
	ДокументРезультат.Вывести(строкаПустая);
	
	макетЛево = макет.ПолучитьОбласть("СтатьяОборота|Лево");
	макетБюджет = макет.ПолучитьОбласть("СтатьяОборота|бюджет1");
	
	макетЛево.Параметры.СтатьяОборота = СтатьяОборотаДляИспользованногоБюджета;
	ДокументРезультат.Вывести(макетЛево);
	
	таб = Итоги.Выгрузить();
	таб.Свернуть("Бюджет", "Использовано");
	
	Если БюджетСписок.Количество() = 0 Тогда
		Бюджеты = таб.Скопировать(, "Бюджет");
		Бюджеты.Свернуть("Бюджет");
	Иначе
		Бюджеты = новый ТаблицаЗначений;
		Бюджеты.Колонки.Добавить("Бюджет");
		Для каждого строка Из БюджетСписок Цикл
			Бюджеты.Добавить().Бюджет = строка.Значение;
		КонецЦикла;
	КонецЕсли;
	
	Если Бюджеты.Количество() > 1 Тогда
		нашли = Бюджеты.Найти(Справочники.гф_Бюджеты.ПустаяСсылка());
		Если не нашли = Неопределено Тогда
			Бюджеты.Удалить(нашли);
		КонецЕсли;
		
		Бюджеты.Колонки.Добавить("Порядок");
		Для каждого строка Из Бюджеты Цикл
			строка.Порядок = строка.Бюджет.Порядок;
		КонецЦикла;
		Бюджеты.Сортировать("Порядок");
	КонецЕсли;
	
	Для каждого строка Из Бюджеты Цикл
		нашли = таб.Найти(строка.Бюджет, "Бюджет");
		Если нашли = Неопределено Тогда
			значение = 0;
		ИНаче
			значение = нашли.Использовано;
		КонецЕсли;
		макетБюджет.Параметры.Бюджет = строка.Бюджет;
		макетБюджет.Параметры.Сумма = значение;
		ДокументРезультат.Присоединить(макетБюджет);
	КонецЦикла;
	
КонецПроцедуры

Процедура ПечатьТаблицыОбороты(ДокументРезультат)
	
	
	макет = ПолучитьМакет("Макет");
		таб = ПолучитьТаблицуОборотов();
	макетЛево = макет.ПолучитьОбласть("ЗаголовокОборотов|Лево");
	ДокументРезультат.Вывести(макетЛево); 
	макетИтогиПоБюджету = макет.ПолучитьОбласть("ИтогиПоБюджету|Лево");  
    ИтогиПоБюджету=Новый ТаблицаЗначений;
    	ИтогиПоБюджету=таб.Скопировать(,"Бюджет,СуммаУпр");  
	ИтогиПоБюджету.Свернуть("Бюджет","СуммаУпр");  
	Для Каждого стрИ из ИтогиПоБюджету Цикл  
		Если ЗначениеЗаполнено(стрИ.Бюджет) Тогда
		макетИтогиПоБюджету.Параметры.Бюджет = стрИ.Бюджет;	
		макетИтогиПоБюджету.Параметры.ИтогоПоБюджету=стрИ.СуммаУпр;
		ДокументРезультат.Вывести(макетИтогиПоБюджету); 
		КонецЕсли;  
       найти=таб.НайтиСтроки(новый Структура("Бюджет", стрИ.Бюджет)); 
	макетИтогиПоСтатье = макет.ПолучитьОбласть("ИтогиПоСтатье1|Лево");  

	ИтогиПоСтатье=Новый ТаблицаЗначений; 
	итогиПоСтатье=таб.СкопироватьКолонки(); 
	ДокументРезультат.НачатьГруппуСтрок(итогиПоСтатье,Ложь);  
	Для каждого строкаМассива из Найти Цикл   
		СтрокаДанных=ИтогиПоСтатье.Добавить();
		 ЗаполнитьЗначенияСвойств(СтрокаДанных,строкаМассива);
		КонецЦикла;
	ИтогиПоСтатье.Свернуть("СтатьяОборотов","СуммаУпр");    
	Для Каждого стр из ИтогиПоСтатье Цикл   
		Если ЗначениеЗаполнено(стр.СтатьяОборотов) Тогда  
		макетИтогиПоСтатье.Параметры.СтатьяОборотов = стр.СтатьяОборотов;	
		макетИтогиПоСтатье.Параметры.ИтогоПоСтатьеОборотов=стр.СуммаУпр; 
		Если стр.СтатьяОборотов.Наименование="Утвержден" Тогда
		СтрокаТЧ=ПланНаДату.Добавить();
		СтрокаТЧ.Бюджет=стрИ.Бюджет;
		СтрокаТЧ.Сумма=стр.СуммаУпр;  
		
	КонецЕсли; 

		ДокументРезультат.Вывести(макетИтогиПоСтатье);   

	КонецЕсли; 
	
	макетСтрокаОборотов = макет.ПолучитьОбласть("СтрокаОборотов|Лево");    
		ДокументРезультат.НачатьГруппуСтрок(макетСтрокаОборотов,Ложь);  
	НайденнаяСтрока=таб.НайтиСтроки(новый Структура("Бюджет,СтатьяОборотов", стрИ.Бюджет,стр.СтатьяОборотов)); 
	Для каждого стрБ из НайденнаяСтрока цикл
		Если ЗначениеЗаполнено(стрБ.СтатьяОборотов) Тогда  
		//ДокументРезультат.НачатьГруппуСтрок(макетСтрокаОборотов,Ложь);  
			макетСтрокаОборотов.Параметры.Контрагент=стрБ.контрагент;
			макетСтрокаОборотов.Параметры.СуммаУпр=стрБ.СуммаУпр;      
			ДокументРезультат.Вывести(макетСтрокаОборотов);
		КонецЕсли;
	КонецЦикла;  
							ДокументРезультат.ЗакончитьГруппуСтрок();

КонецЦикла; 
    						ДокументРезультат.ЗакончитьГруппуСтрок();


					КонецЦикла;  
					

	//ДокументРезультат.ЗакончитьГруппуСтрок();
	макетИтогоПоОборотам = макет.ПолучитьОбласть("ИтогоПоОборотам|Лево"); 
    макетИтогоПоОборотам.Параметры.ИтогоОборотов=таб.Итог("СуммаУпр");
	ДокументРезультат.Вывести(макетИтогоПоОборотам);
	
КонецПроцедуры

Функция ПолучитьТаблицуИтоговыйРезультат()
	
	схема = ПолучитьМакет("ИтоговыйРезультат");
	Компоновщик = новый КомпоновщикНастроекКомпоновкиДанных;
	Компоновщик.Инициализировать(новый ИсточникДоступныхНастроекКомпоновкиДанных(схема));
	Компоновщик.ЗагрузитьНастройки(схема.НастройкиПоУмолчанию);
	
	ПараметрыДанных = Компоновщик.Настройки.ПараметрыДанных;
	ПараметрыДанных.УстановитьЗначениеПараметра("ДатаОкончания", КонецДня(ДатаОкончания));
	ПараметрыДанных.УстановитьЗначениеПараметра("Бюджет", БюджетСписок);
	ПараметрыДанных.УстановитьЗначениеПараметра("НетБюджетов", БюджетСписок.Количество() = 0);
	
	Отборы = Компоновщик.Настройки.Отбор.Элементы;
	Для каждого строка Из КомпоновщикНастроек.Настройки.Отбор.Элементы Цикл
		новая = Отборы.Добавить(тип("ЭлементОтбораКомпоновкиДанных"));
		ЗаполнитьЗначенияСвойств(новая, строка);
	КонецЦикла;
	Для Каждого ЭлементБазовый Из КомпоновщикНастроек.Настройки.Отбор.Элементы Цикл
		Если ЭлементБазовый.Представление = "Организация" Тогда
			ЭлементБазовый.ПравоеЗначение = Организации;
			ЭлементБазовый.Использование=Истина;
			Прервать;
		КонецЕсли;                                                 
	КонецЦикла;

	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных; 
	МакетКомпоновки = КомпоновщикМакета.Выполнить(схема, Компоновщик.ПолучитьНастройки(),,, Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных; 
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,,, Истина); 
	
	таб = новый ТаблицаЗначений;
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.ОтображатьПроцентВывода = Истина;
	ПроцессорВывода.УстановитьОбъект(таб);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	возврат таб;
КонецФункции

Процедура ПечатьТаблицыИтоговыйРезультат(ДокументРезультат, ПланНаДату)
	
	таб = ПолучитьТаблицуИтоговыйРезультат();
	Для каждого строка Из итоги Цикл
		Если БюджетСписок.Количество() = 0 или не БюджетСписок.НайтиПоЗначению(строка.Бюджет) = Неопределено Тогда
			новая = таб.Добавить();
			новая.Бюджет = строка.Бюджет;
			новая.СуммаУпр = -строка.Использовано;
		КонецЕсли;
	КонецЦикла;
	
	//Для каждого строка Из ПланНаДату Цикл
	//	новая = таб.Добавить();
	//	новая.Бюджет = строка.Бюджет;
	//	новая.СуммаУпр = -строка.Сумма;
	//КонецЦикла;
	
	таб.Свернуть("Бюджет", "СуммаУпр");
	
	Если таб.Количество() > 1 Тогда
		таб.Колонки.Добавить("Порядок");
		Для каждого строка Из таб Цикл
			Если ЗначениеЗаполнено(строка.Бюджет) Тогда
				строка.Порядок = строка.Бюджет.Порядок;
			Иначе
				строка.Порядок = -1;
			КонецЕсли;
		КонецЦикла;
		таб.Сортировать("Порядок");
	КонецЕсли;
	
	макет = ПолучитьМакет("Макет");
	строкаПустая = макет.ПолучитьОбласть("строкаПустая");
	ДокументРезультат.Вывести(строкаПустая);
	
	Таблица3 = макет.ПолучитьОбласть("Таблица3|Лево");
	Таблица3_1 = макет.ПолучитьОбласть("Таблица3|Бюджет1");
	Таблица3_2 = макет.ПолучитьОбласть("Таблица3|Бюджет2");
	
	ДокументРезультат.Вывести(Таблица3);
	
	нашли = таб.Найти(Справочники.гф_Бюджеты.ПустаяСсылка());
	Если не нашли = Неопределено Тогда
		таб.Удалить(нашли);
	КонецЕсли;
	
	перваяколонка = Истина;
	Для каждого строка Из таб Цикл
		Если перваяколонка Тогда
			макетколонки = Таблица3_1;
			перваяколонка = Ложь;
		Иначе
			макетколонки = Таблица3_2;
		КонецЕсли;
		
		макетколонки.Параметры.Бюджет = строка.Бюджет;
		макетколонки.Параметры.Сумма = строка.СуммаУпр;
		ДокументРезультат.Присоединить(макетколонки);
	КонецЦикла;
	
КонецПроцедуры
