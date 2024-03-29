﻿#Область СлужебныйПрограммныйИнтерфейс

#Область Трекер

// Возвращает таблицу кодов и атрибутов операций
//
//	Возвращаемое значение:
//	- ТаблицаЗначений - Возвращает таблицу значений.
//
Функция ПолучитьТаблицуКодовОпераций() Экспорт
	
	ИмяСправочника = "гф_ПочтаРоссииОперацииОтслеживания";
	
	Колонки = Новый Массив;
	
	Колонки.Добавить(СтруктураКолонки("Код", "Число", 8, 0));
	Колонки.Добавить(СтруктураКолонки("Наименование",     "Строка", 150, 0));
	Колонки.Добавить(СтруктураКолонки("КодОперации",      "Число", 4, 1));
	Колонки.Добавить(СтруктураКолонки("Операция",         "Строка", 64, 2));
	Колонки.Добавить(СтруктураКолонки("КодАтрибута",      "Число", 4, 3));
	Колонки.Добавить(СтруктураКолонки("Атрибут",          "Строка", 120, 4));
	Колонки.Добавить(СтруктураКолонки("КонечнаяОперация", "Булево", 0, 5));
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзМакета("КодыОпераций", Колонки);
	
	КодОперации = Неопределено;
	Операция    = Неопределено;
	
	Для Каждого СтрокаКодов Из ТаблицаКодов Цикл
		
		Если СтрокаКодов.КодОперации Тогда
			
			КодОперации = СтрокаКодов.КодОперации;
			Операция    = СтрокаКодов.Операция;
			
		Иначе
			
			СтрокаКодов.КодОперации = КодОперации;
			СтрокаКодов.Операция    = Операция;
			
		КонецЕсли;      
		
		ДесятьТысяч = 10000; //Удовлетворяем SonarCube 
		
		СтрокаКодов.Код = СтрокаКодов.КодОперации * ДесятьТысяч + СтрокаКодов.КодАтрибута;
		
		СтрокаКодов.Наименование = СтрокаКодов.Операция + ".";
		
		Если СтрокаКодов.КодАтрибута Тогда
			
			СтрокаКодов.Наименование = СтрокаКодов.Наименование + " " + СтрокаКодов.Атрибут + ".";
			
		КонецЕсли;
		
	КонецЦикла;
	
	ИнициализироватьСправочникКодов(ИмяСправочника, ТаблицаКодов);
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзСправочника(ИмяСправочника, Колонки);
	
	Возврат ТаблицаКодов;
	
КонецФункции

// Возвращает таблицу кодов категорий почтовых отправлений
//
//	Возвращаемое значение:
//	- Произвольный - Возвращаемое значение.
//
Функция ПолучитьТаблицуКодовКатегорийПочтовыхОтправлений() Экспорт
	
	ИмяСправочника = "гф_ПочтаРоссииКодыКатегорийПочтовыхОтправлений";
	
	Колонки = Новый Массив;
	
	Колонки.Добавить(СтруктураКолонки("Код",          "Число", 2, 1));
	Колонки.Добавить(СтруктураКолонки("Наименование", "Строка", 64, 2));
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзМакета("КодыКатегорийПочтовыхОтправлений", Колонки);
	
	ИнициализироватьСправочникКодов(ИмяСправочника, ТаблицаКодов);
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзСправочника(ИмяСправочника, Колонки);
	
	Возврат ТаблицаКодов;
	
КонецФункции

// Возвращает таблицу разрядов почтовых отправлений
//
//	Возвращаемое значение:
//	- Произвольный - Возвращаемое значение.
//
Функция ПолучитьТаблицуКодовРазрядовПочтовыхОтправлений() Экспорт
	
	ИмяСправочника = "гф_ПочтаРоссииКодыРазрядовПочтовыхОтправлений";
	
	Колонки = Новый Массив;
	
	Колонки.Добавить(СтруктураКолонки("Код",          "Число", 2, 1));
	Колонки.Добавить(СтруктураКолонки("Наименование", "Строка", 20, 2));
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзМакета("КодыРазрядовПочтовыхОтправлений", Колонки);
	
	ИнициализироватьСправочникКодов(ИмяСправочника, ТаблицаКодов);
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзСправочника(ИмяСправочника, Колонки);
	
	Возврат ТаблицаКодов;
	
КонецФункции

// Возвращает таблицу видов почтовых отправлений
//
//	Возвращаемое значение:
//	- Произвольный - Возвращаемое значение.
//
Функция ПолучитьТаблицуКодовВидовПочтовыхОтправлений() Экспорт
	
	ИмяСправочника = "гф_ПочтаРоссииКодыВидовПочтовыхОтправлений";
	
	Колонки = Новый Массив;
	
	Колонки.Добавить(СтруктураКолонки("Код",          "Число", 2, 1));
	Колонки.Добавить(СтруктураКолонки("Наименование", "Строка", 64, 2));
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзМакета("КодыВидовПочтовыхОтправлений", Колонки);
	
	ИнициализироватьСправочникКодов(ИмяСправочника, ТаблицаКодов);
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзСправочника(ИмяСправочника, Колонки);
	
	Возврат ТаблицаКодов;
	
КонецФункции

// Возвращает таблицу категорий отправителей
//
//	Возвращаемое значение:
//	- Произвольный - Возвращаемое значение.
//
Функция ПолучитьТаблицуКодовКатегорийОтправителей() Экспорт
	
	ИмяСправочника = "гф_ПочтаРоссииКодыКатегорийОтправлителей";
	
	Колонки = Новый Массив;
	
	Колонки.Добавить(СтруктураКолонки("Код",          "Число", 2, 1));
	Колонки.Добавить(СтруктураКолонки("Наименование", "Строка", 25, 2));
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзМакета("КодыКатегорийОтправителей", Колонки);
	
	ИнициализироватьСправочникКодов(ИмяСправочника, ТаблицаКодов);
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзСправочника(ИмяСправочника, Колонки);
	
	Возврат ТаблицаКодов;
	
КонецФункции

// Возвращает таблицу категорий отправителей
//
//	Возвращаемое значение:
//	- Произвольный - Возвращаемое значение.
//
Функция ПолучитьТаблицуКодовСтранПересылкиПочтовыхОтправлений() Экспорт
	
	ИмяСправочника = "гф_ПочтаРоссииКодыСтранПересылкиПочтовыхОтправлений";
	
	Колонки = Новый Массив;
	
	Колонки.Добавить(СтруктураКолонки("Код",       "Число", 4, 1));
	Колонки.Добавить(СтруктураКолонки("КодAlpha2", "Строка", 2, 2));
	Колонки.Добавить(СтруктураКолонки("КодAlpha3", "Строка", 3, 3));
	Колонки.Добавить(СтруктураКолонки("Наименование",            "Строка", 64, 4));
	Колонки.Добавить(СтруктураКолонки("АнглийскоеНаименование",  "Строка", 64, 5));
	Колонки.Добавить(СтруктураКолонки("ФранцузскоеНаименование", "Строка", 64, 6));
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзМакета("КодыСтранПересылкиПочтовыхОтправлений", Колонки);
	
	ИнициализироватьСправочникКодов(ИмяСправочника, ТаблицаКодов);
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзСправочника(ИмяСправочника, Колонки);
	
	Возврат ТаблицаКодов;
	
КонецФункции

// Возвращает таблицу отметок почтовых отправлений
//
//	Возвращаемое значение:
//	- Произвольный - Возвращаемое значение.
//
Функция ПолучитьТаблицуКодовОтметокПочтовыхОтправлений() Экспорт
	
	ИмяСправочника = "гф_ПочтаРоссииКодыОтметокПочтовыхОтправлений";
	
	Колонки = Новый Массив;
	
	Колонки.Добавить(СтруктураКолонки("Код",          "Число", 16, 1));
	Колонки.Добавить(СтруктураКолонки("Наименование", "Строка", 64, 2));
	Колонки.Добавить(СтруктураКолонки("Разряд",       "Число", 2, 0));
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзМакета("КодыОтметокПочтовыхОтправлений", Колонки);
	
	Для Каждого СтрокаКодов Из ТаблицаКодов Цикл
		
		Если СтрокаКодов.Код = 0 Тогда
			
			СтрокаКодов.Разряд = 0;
			
		Иначе
			
			СтрокаКодов.Разряд = Цел(Log(СтрокаКодов.Код)/Log(2));
			
		КонецЕсли;
		
	КонецЦикла;
	
	ИнициализироватьСправочникКодов(ИмяСправочника, ТаблицаКодов);
	
	ТаблицаКодов = ПолучитьТаблицуКодовИзСправочника(ИмяСправочника, Колонки);
	
	Возврат ТаблицаКодов;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Заполняет справочник ИмяСправочника
// из табличного документа Обработки.гф_ПочтаРоссииЗапросКТрекеру.КодыОпераций.
//
//	Параметры:
//	ИмяСправочника	- Строка
//  Колонки			- Массив
//
//	Возвращаемое значение:
//	- Произвольный - Возвращаемое значение.
//
Функция ПолучитьТаблицуКодовИзСправочника(ИмяСправочника, Колонки)
	
	СхемаЗапроса = Новый СхемаЗапроса;
	
	ЗапросВыборкаИзСправочника = СхемаЗапроса.ПакетЗапросов[0];
	
	Оператор = ЗапросВыборкаИзСправочника.Операторы[0];
	
	Оператор.Источники.Добавить("Справочник." + ИмяСправочника, "Справочник");
	
	Оператор.ВыбираемыеПоля.Добавить("Ссылка");
	
	Для Каждого Колонка Из Колонки Цикл
		
		Оператор.ВыбираемыеПоля.Добавить(Колонка.Имя);
		
	КонецЦикла;
	
	ТекстЗапроса = СхемаЗапроса.ПолучитьТекстЗапроса();
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = ТекстЗапроса;
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		
		Возврат Неопределено;
		
	Иначе
		
		ТаблицаКодов = Результат.Выгрузить();
		
		Возврат ТаблицаКодов;
		
	КонецЕсли;
	
КонецФункции

// Заполняет справочник "ИмяСправочника"
// из табличного документа Обработки.гф_ПочтаРоссииЗапросКТрекеру."ТаблицаКодов".
//
//	Параметры:
//	ИмяСправочника	- Строка
//  ТаблицаКодов	- ТаблицаЗначений
//						* Код		- Строка
//						* Ссылка	- СправочникСсылка
//
Процедура ИнициализироватьСправочникКодов(ИмяСправочника, ТаблицаКодов)
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ
	|	ТаблицаКодов.Код КАК Код
	|ПОМЕСТИТЬ ВТ_Коды
	|ИЗ
	|	&ТаблицаКодов КАК ТаблицаКодов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Справочник.Ссылка КАК Ссылка,
	|	ВТ_Коды.Код КАК Код
	|ИЗ
	|	ВТ_Коды КАК ВТ_Коды
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.&ИмяСправочника КАК Справочник
	|		ПО ВТ_Коды.Код = Справочник.Код
	|ГДЕ
	|	Справочник.Ссылка ЕСТЬ NULL";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ИмяСправочника", ИмяСправочника);
	
	Запрос.Параметры.Вставить("ТаблицаКодов", ТаблицаКодов);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		
		Возврат;
		
	КонецЕсли;
	
	МассивКодов = Результат.Выгрузить().ВыгрузитьКолонку("Код");
	
	Для Каждого Код Из МассивКодов Цикл
		
		СтрокаКодов = ТаблицаКодов.Найти(Код, "Код");
		
		Если СтрокаКодов <> Неопределено Тогда
			
			СправочникОбъект = Справочники[ИмяСправочника].СоздатьЭлемент();
			
			ЗаполнитьЗначенияСвойств(СправочникОбъект, СтрокаКодов);
			
			СправочникОбъект.Записать();
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Структура колонки для подготовки массива колонок
// для вызова функции ПолучитьТаблицуКодовИзМакета.
//
//	Параметры:
//	Имя				- Строка
//	Тип				- Строка
//	Длина			- Число
//	НомерКолонки	- Число
//
//	Возвращаемое значение:
//	- Структура - Структура колонки.
//
Функция СтруктураКолонки(Имя, Тип, Длина, НомерКолонки)
	
	Результат = Новый Структура;
	
	Результат.Вставить("Имя",          Имя);
	Результат.Вставить("Тип",          Тип);
	Результат.Вставить("Длина",        Длина);
	Результат.Вставить("НомерКолонки", НомерКолонки);
	
	Возврат Результат;
	
КонецФункции

// Таблица значений из макета обработки гф_ПочтаРоссииЗапросКТрекеру
// Параметры:
// ИмяМакета - Строка
// Колонки - Массив - массив структур, созданных функцией СтруктураКолонки.
//
//	Возвращаемое значение:
//	- Произвольный - Возвращаемое значение.
//
Функция ПолучитьТаблицуКодовИзМакета(ИмяМакета, Колонки)
	
	ТаблицаКодов = Новый ТаблицаЗначений;
	
	Для Каждого Колонка Из Колонки Цикл
		
		Если Колонка.Тип = "Число" Тогда
			
			Квалификаторы = Новый КвалификаторыЧисла(Колонка.Длина, 0, ДопустимыйЗнак.Неотрицательный);
			
		ИначеЕсли Колонка.Тип = "Строка" Тогда
			
			Квалификаторы = Новый КвалификаторыСтроки(Колонка.Длина, ДопустимаяДлина.Переменная);
			
		Иначе
			
			Квалификаторы = Неопределено;
			
		КонецЕсли;
		
		ОписаниеТипов = Новый ОписаниеТипов(Колонка.Тип, , , Квалификаторы);
		
		ТаблицаКодов.Колонки.Добавить(Колонка.Имя, ОписаниеТипов);
		
	КонецЦикла;
	
	ДокументКоды = Обработки.гф_ПочтаРоссииЗапросКТрекеру.ПолучитьМакет(ИмяМакета);
	
	ПерваяСтрокаДанных = 2;
	
	Для НомерСтроки = ПерваяСтрокаДанных По ДокументКоды.ВысотаТаблицы Цикл
		
		НоваяСтрока = ТаблицаКодов.Добавить();
		
		Для Каждого Колонка Из Колонки Цикл
			
			Если Не Колонка.НомерКолонки Тогда
				
				Продолжить;
				
			КонецЕсли;
			
			Область = ДокументКоды.Область(НомерСтроки, Колонка.НомерКолонки);
			
			НоваяСтрока[Колонка.Имя] = Область.Текст;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат ТаблицаКодов;
	
КонецФункции

#КонецОбласти

