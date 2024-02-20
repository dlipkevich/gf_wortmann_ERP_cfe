﻿#Область ПрограммныйИнтерфейс

Функция ЕстьПолныеПрава() Экспорт
	Возврат РольДоступна("ПолныеПрава");
КонецФункции

Функция ЕстьПраваЭксперта() Экспорт
	Возврат ЕстьПолныеПрава();
КонецФункции

Функция ЕстьПравоДоступа(Право, ПолноеИмяМД) Экспорт
	Возврат ПравоДоступа(Право, Метаданные.НайтиПоПолномуИмени(ПолноеИмяМД));
КонецФункции

Функция ПроверитьНаличиеПравЭкспертаПоКонфигурации(Отказ) Экспорт
	Если Не ЕстьПраваЭксперта() Тогда
		Возврат _омОбщегоНазначенияКлиентСервер.СообщитьОбОшибке("Нет прав на выполнение операции!", Отказ);
	КонецЕсли;
	
	Возврат Истина;
КонецФункции

// Возвращает значения реквизита, прочитанного из информационной базы по ссылке на объект.
// Рекомендуется использовать вместо обращения к реквизитам объекта через точку от ссылки на объект
// для быстрого чтения отдельных реквизитов объекта из базы данных.
//
// Если необходимо зачитать реквизит независимо от прав текущего пользователя,
// то следует использовать предварительный переход в привилегированный режим.
//
// Параметры:
//  Ссылка    - ЛюбаяСсылка - объект, значения реквизитов которого необходимо получить.
//  ТаблицаОбъекта - Строка - имя таблицы метаданных 
//                   (напр. "Справочник.Организации", "ПлатежныйДокумент.РасшифровкаПлатежа").
//  ИмяРеквизита - Строка - имя получаемого реквизита.
//  ЗначениеПоУмолчанию - ВсеТипы - значение, которое будет возвращаться если значение реквизита получить не удалось,
//                   по умолчанию возвращается Неопределено.
//  ВыбратьРазрешенные - Булево - если Истина, то запрос к объекту выполняется с учетом прав пользователя.
//
// Возвращаемое значение:
//  Произвольный - если в параметр Ссылка передана пустая ссылка, то возвращается Неопределено или ЗначениеПоУмолчанию
//                 Если в параметр Ссылка передана ссылка несуществующего объекта (битая ссылка),
//                 то возвращается Неопределено или ЗначениеПоУмолчанию.
//
Функция ЗначениеРеквизитаОбъекта(Знач Ссылка, 
	Знач ТаблицаОбъекта, 
	Знач ИмяРеквизита, 
	ЗначениеПоУмолчанию = Неопределено, 
	ВыбратьРазрешенные = Ложь) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Запрос.Текст =
	"ВЫБРАТЬ" + ?(ВыбратьРазрешенные, " РАЗРЕШЕННЫЕ", "") + " ПЕРВЫЕ 1
	|	т." + ИмяРеквизита + " КАК Значение
	|ИЗ
	|	" + ТаблицаОбъекта + " КАК т
	|ГДЕ
	|	т.Ссылка = &Ссылка";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Возврат ?(Выборка.Следующий(), Выборка.Значение, ЗначениеПоУмолчанию);
КонецФункции

Функция ЗначенияРеквизитовОбъекта(Знач Ссылка, 
	Знач ТаблицаОбъекта, 
	Знач ПереченьРеквизитов, 
	ВыбратьРазрешенные = Ложь) Экспорт
	
	пСтруктура = Новый Структура(ПереченьРеквизитов);
	
	ПоляЗапроса = "";
	Для каждого Элем Из пСтруктура Цикл
		ПоляЗапроса = ПоляЗапроса + ?(ПоляЗапроса = "", "", ",") + "
		|	т." + Элем.Ключ + " КАК " + Элем.Ключ;
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Запрос.Текст =
	"ВЫБРАТЬ" + ?(ВыбратьРазрешенные, " РАЗРЕШЕННЫЕ", "") + " ПЕРВЫЕ 1" + ПоляЗапроса + "
	|ИЗ
	|	" + ТаблицаОбъекта + " КАК т
	|ГДЕ
	|	т.Ссылка = &Ссылка";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		ЗаполнитьЗначенияСвойств(пСтруктура, Выборка);
	КонецЕсли;
	
	Возврат пСтруктура;
КонецФункции

Функция ПолучитьГлобальноеЗначение(Имя, 
	ЗначениеПоУмолчанию = Неопределено,
	ЗаменитьНеопределеноНаЗначениеПоУмолчанию = Ложь) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Имя", Имя);
	
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	тДанные.Значение КАК Значение
	|ИЗ
	|	ПланВидовХарактеристик.гф_ГлобальныеЗначения КАК тДанные
	|ГДЕ
	|	тДанные.Ключ = &Имя";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат ?(ЗаменитьНеопределеноНаЗначениеПоУмолчанию И Выборка.Значение = Неопределено, 
		ЗначениеПоУмолчанию, Выборка.Значение);
	КонецЕсли;
	
	Возврат ЗначениеПоУмолчанию;
КонецФункции

Функция ПолучитьГлобальноеЗначениеМассив(Имя) Экспорт
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Имя", Имя);
	
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	т.Ссылка КАК Ссылка
	|ПОМЕСТИТЬ Характеристика
	|ИЗ
	|	ПланВидовХарактеристик.гф_ГлобальныеЗначения КАК т
	|ГДЕ
	|	т.Ключ = &Имя
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	тДанные.Значение КАК Значение
	|ИЗ
	|	ПланВидовХарактеристик.гф_ГлобальныеЗначения.Список КАК тДанные
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Характеристика КАК Характеристика
	|		ПО тДанные.Ссылка = Характеристика.Ссылка";
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Значение");
КонецФункции

Функция ПолучитьГлобальноеЗначениеСАвторизацией(Имя) Экспорт
	УстановитьПривилегированныйРежим(Истина);
	
	пСтруктура = Новый Структура("ЕстьДанные, Значение, Логин, Пароль", Ложь);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Имя", Имя);
	
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	тДанные.Значение КАК Значение,
	|	тДанные.ДанныеХЗ КАК ДанныеХЗ
	|ИЗ
	|	ПланВидовХарактеристик.гф_ГлобальныеЗначения КАК тДанные
	|ГДЕ
	|	тДанные.Ключ = &Имя";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		ДанныеХЗ = Выборка.ДанныеХЗ.Получить();
		Если ТипЗнч(ДанныеХЗ) = Тип("Структура") Тогда
			ЗаполнитьЗначенияСвойств(пСтруктура, ДанныеХЗ);
		КонецЕсли;
		
		пСтруктура.ЕстьДанные = Истина;
		пСтруктура.Значение = Выборка.Значение;
	КонецЕсли;
	
	Возврат пСтруктура;
КонецФункции

// Галфинд Домнышева 01_09_22
// Параметры:
//  Имя - Строка - ключ значения указанный в предприятии.
//
// Возвращаемое значение:
//  Структура - Структура параметров заполненных в Предприятии
// BSLLS:LatinAndCyrillicSymbolInWord-off
Функция ПолучитьГлобальноеЗначениеFTP(Имя) Экспорт
// BSLLS:LatinAndCyrillicSymbolInWord-on
	УстановитьПривилегированныйРежим(Истина);
	
	пСтруктура = Новый Структура; 
	пСтруктура.Вставить("ЕстьДанные", "");
	пСтруктура.Вставить("Значение", "");
	пСтруктура.Вставить("Сервер", "");
	пСтруктура.Вставить("Порт", 21);
	пСтруктура.Вставить("Пользователь", "");
	пСтруктура.Вставить("Пароль", "");
	пСтруктура.Вставить("ПользовательПрокси", "");
	пСтруктура.Вставить("ПарольПрокси", "");
	пСтруктура.Вставить("Каталог", "");
	пСтруктура.Вставить("ПассивноеСоединение", Ложь);
	пСтруктура.Вставить("Таймаут", 10);
	пСтруктура.Вставить("SSL", Ложь);   //Добавлено  Галфинд \ Sakovich 18.01.2024 
	// ++ Галфинд_ДомнышеваКР_19_02_2024
	пСтруктура.Вставить("IN", "");
	пСтруктура.Вставить("OUT", "");
	пСтруктура.Вставить("LOG", "");
	// -- Галфинд_ДомнышеваКР_19_02_2024
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Имя", Имя);
	
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	тДанные.Значение КАК Значение,
	|	тДанные.ДанныеХЗ КАК ДанныеХЗ
	|ИЗ
	|	ПланВидовХарактеристик.гф_ГлобальныеЗначения КАК тДанные
	|ГДЕ
	|	тДанные.Ключ = &Имя";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		ДанныеХЗ = Выборка.ДанныеХЗ.Получить();
		Если ТипЗнч(ДанныеХЗ) = Тип("Структура") Тогда
			ЗаполнитьЗначенияСвойств(пСтруктура, ДанныеХЗ);
		КонецЕсли;
		
		пСтруктура.ЕстьДанные = Истина;
		пСтруктура.Значение = Выборка.Значение;
	КонецЕсли;
	
	Возврат пСтруктура;
КонецФункции

// Галфинд Домнышева 30_09_22
// Параметры:
//  Настройки - Структура - Структура параметров FTPСоединения
//
// Возвращаемое значение:
//  Соединение - в случае удачного подключения FTPСоединение, неудачного - Неопределено
Функция гф_ПолучитьСоединение(Настройки) Экспорт
	
	ИспользоватьПроксиСервер = Ложь;	
	// отправление данных на ftp
	Если ЗначениеЗаполнено(Настройки.ПользовательПрокси) Тогда
		ИспользоватьПроксиСервер = Истина;
		ПроксиСервер = Новый ИнтернетПрокси(Ложь);
		ПроксиСервер.НеИспользоватьПроксиДляАдресов.Очистить();
		ПроксиСервер.Пользователь = СокрЛП(Настройки.ПользовательПрокси);
		ПроксиСервер.Пароль = СокрЛП(Настройки.ПарольПрокси);
		ПортПрокси = ?(Настройки.ПортПрокси = 0, 8080, Настройки.ПортПрокси);
		ПроксиСервер.Установить(СокрЛП(Настройки.ПротоколПрокси), СокрЛП(Настройки.АдресПрокси), ПортПрокси);
	КонецЕсли;
	
	Сервер = СокрЛП(Настройки.Сервер);
	Порт = ?(Настройки.Порт = 0, 21, Настройки.Порт);
	ИмяПользователя = СокрЛП(Настройки.Пользователь);
	ПарольПользователя = СокрЛП(Настройки.Пароль);
	
	Попытка
		Соединение = ?(ИспользоватьПроксиСервер,
		Новый FTPСоединение(Сервер, Порт, ИмяПользователя, ПарольПользователя, ПроксиСервер, , 300), 
		Новый FTPСоединение(Сервер, Порт, ИмяПользователя, ПарольПользователя, , Истина, 300));
		
		Возврат Соединение;
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
КонецФункции

// Галфинд Домнышева 10_10_22
// Функция возвращает в случае успешного соединения с SFTP сервером Соединение.
// Параметры:
//  Настройки - Структура - Структура параметров FTPСоединения
//  Отказ - параметр систем
//
// Возвращаемое значение:
//  Соединение - в случае удачного подключения SFTPСоединение, неудачного - Неопределено
// BSLLS:LatinAndCyrillicSymbolInWord-off
Функция ПолучитьСоединениеSFTP(Настройки, Отказ) Экспорт
// BSLLS:LatinAndCyrillicSymbolInWord-on	
	Если ЗначениеЗаполнено(Настройки.ПользовательПрокси) Тогда
		Отказ = Истина;
		Возврат Неопределено;
	КонецЕсли;
	
	Попытка
		РасположениеWinSCP = _омОбщегоНазначенияВызовСервера.ПолучитьГлобальноеЗначение("гф_РасположениеWinSCP");
		
		ОпцииСессии = Новый COMОбъект("WinSCP.SessionOptions");
		ОпцииСессии.HostName = СокрЛП(Настройки.Сервер);
		ОпцииСессии.PortNumber = Настройки.Порт;
		ОпцииСессии.UserName = СокрЛП(Настройки.Пользователь);
		ОпцииСессии.Password = СокрЛП(Настройки.Пароль);
		
		// ++ Галфинд_ДомнышеваКР_12_01_2024
		// Изменено на ключ для сервера заказчика
		//ОпцииСессии.SshHostKeyFingerprint = "ssh-rsa 1024 U7gTHqAEWWcc9s4RaafFus7Ijsdvqbd/3IS8Juih3ys";
		ОпцииСессии.SshHostKeyFingerprint = "ssh-rsa 2048 4QC6Wsnsu6Hp7wUM3FfTKf+7X/N8dUig5SCv1FADfv4=";
		// -- Галфинд_ДомнышеваКР_12_01_2024
		
		ОпцииСессии.TimeoutInMilliseconds = 5000;
		
		Соединение = Новый COMОбъект("WinSCP.Session");
		Соединение.ExecutablePath = РасположениеWinSCP + "\winscp.exe"; 
		
		Соединение.Open(ОпцииСессии);
	Исключение
		Отказ = Истина;
		СообщениеОбОшибке = "Ошибка при настройке соединения WinSCP " + ". Описание ошибки: "+ ОписаниеОшибки();
		ЗаписьЖурналаРегистрации("СоединениеSFTP", УровеньЖурналаРегистрации.Ошибка, , , СообщениеОбОшибке);
		Сообщить(СообщениеОбОшибке);
		Возврат Неопределено;
	КонецПопытки;
	
	Возврат Соединение;
	
КонецФункции 

Функция ЗначениеВМассив(Значение) Экспорт
	Массив = Новый Массив;
	Массив.Добавить(Значение);
	
	Возврат Массив;
КонецФункции

Функция ОписаниеТипаСуммаБУ() Экспорт
	Возврат Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15, 2));
КонецФункции

Функция ОписаниеТипаСуммаУХ() Экспорт
	Возврат Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(18, 5));
КонецФункции

#Область ПРОЦЕДУРЫ_И_ФУНКЦИИ_ДЛЯ_РАБОТЫ_С_УНИВЕРСАЛЬНЫМИ_КОЛЛЕКЦИЯМИ

Функция СкопироватьУниверсальнуюКоллекцию(Коллекция) Экспорт
	Если ТипЗнч(Коллекция) = Тип("Массив") Тогда
		Результат = Новый Массив;
		Для каждого Элем Из Коллекция Цикл
			Результат.Добавить(Элем);
		КонецЦикла;
		
	ИначеЕсли ТипЗнч(Коллекция) = Тип("Соответствие") Тогда
		Результат = Новый Соответствие;
		Для каждого Элем Из Коллекция Цикл
			Результат.Вставить(Элем.Ключ, Элем.Значение);
		КонецЦикла;
		
	ИначеЕсли ТипЗнч(Коллекция) = Тип("Структура") Тогда
		Результат = Новый Структура;
		Для каждого Элем Из Коллекция Цикл
			Результат.Вставить(Элем.Ключ, Элем.Значение);
		КонецЦикла;
		
	ИначеЕсли ТипЗнч(Коллекция) = Тип("ТаблицаЗначений") 
		ИЛИ ТипЗнч(Коллекция) = Тип("ДеревоЗначений") Тогда
		Результат = Коллекция.Скопировать();
		
	Иначе
		Результат = Коллекция;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

Функция СкопироватьУниверсальнуюКоллекциюРекурсивно(Коллекция) Экспорт
	Если ТипЗнч(Коллекция) = Тип("Массив") Тогда
		Результат = Новый Массив;
		Для каждого Элем Из Коллекция Цикл
			Результат.Добавить(СкопироватьУниверсальнуюКоллекциюРекурсивно(Элем));
		КонецЦикла;
		
	ИначеЕсли ТипЗнч(Коллекция) = Тип("Соответствие") Тогда
		Результат = Новый Соответствие;
		Для каждого Элем Из Коллекция Цикл
			Результат.Вставить(Элем.Ключ, СкопироватьУниверсальнуюКоллекциюРекурсивно(Элем.Значение));
		КонецЦикла;
		
	ИначеЕсли ТипЗнч(Коллекция) = Тип("Структура") Тогда
		Результат = Новый Структура;
		Для каждого Элем Из Коллекция Цикл
			Результат.Вставить(Элем.Ключ, СкопироватьУниверсальнуюКоллекциюРекурсивно(Элем.Значение));
		КонецЦикла;
		
	ИначеЕсли ТипЗнч(Коллекция) = Тип("ТаблицаЗначений") 
		ИЛИ ТипЗнч(Коллекция) = Тип("ДеревоЗначений") Тогда
		Результат = Коллекция.Скопировать();
		
	Иначе
		Результат = Коллекция;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции
	
#КонецОбласти

#Область ПРОЦЕДУРЫ_И_ФУНКЦИИ_ДЛЯ_РАБОТЫ_С_ТАБЛИЦАМИ_ЗНАЧЕНИЙ

Функция ИменаЧисловыхКолонокТаблицы(Таблица) Экспорт
	типЧисло = Тип("Число");
	списокПолей = "";
	Для каждого Элем Из Таблица.Колонки Цикл
		Если Элем.ТипЗначения.СодержитТип(типЧисло) Тогда
			списокПолей = списокПолей + ", " + Элем.Имя;
		КонецЕсли;
	КонецЦикла;
	Возврат Сред(списокПолей, 3);
КонецФункции

Функция ИменаНеЧисловыхКолонокТаблицы(Таблица) Экспорт
	типЧисло = Тип("Число");
	списокПолей = "";
	Для каждого Элем Из Таблица.Колонки Цикл
		Если Не Элем.ТипЗначения.СодержитТип(типЧисло) Тогда
			списокПолей = списокПолей + ", " + Элем.Имя;
		КонецЕсли;
	КонецЦикла;
	Возврат Сред(списокПолей, 3);
КонецФункции

Функция СвернутьТаблицуПоЧисловымПолям(Таблица) Экспорт
	Если Таблица.Количество() > 1 Тогда
		ЧисловыеПоля = ИменаЧисловыхКолонокТаблицы(Таблица);
		Таблица.Свернуть(, ЧисловыеПоля);
	КонецЕсли;
	
	Возврат Истина;
КонецФункции

Функция СвернутьТаблицуПоВсемПолям(Таблица) Экспорт
	Если Таблица.Количество() > 1 Тогда
		ЧисловыеПоля = ИменаЧисловыхКолонокТаблицы(Таблица);
		НеЧисловыеПоля = ИменаНеЧисловыхКолонокТаблицы(Таблица);
		Таблица.Свернуть(НеЧисловыеПоля, ЧисловыеПоля);
	КонецЕсли;
	
	Возврат Истина;
КонецФункции

Функция УдалитьСтрокиТаблицы(Знач Таблица, СтруктураОтбора) Экспорт
	массивСтрок = Таблица.НайтиСтроки(СтруктураОтбора);
	
	Для каждого Элем Из массивСтрок Цикл
		Таблица.Удалить(Элем);
	КонецЦикла;
	
	Возврат Истина;
КонецФункции

Функция ВыгрузитьКолонкуВСвернутыйМассив(Знач Таблица, ИмяКолонки, НеИспользоватьНеопределено = Ложь) Экспорт
	Таб = Таблица.Скопировать(, ИмяКолонки);
	Таб.Свернуть(ИмяКолонки);
	
	Если НеИспользоватьНеопределено Тогда
		УдалитьСтрокиТаблицы(Таб, Новый Структура(ИмяКолонки, Неопределено));
	КонецЕсли;
	
	Возврат Таб.ВыгрузитьКолонку(0);
КонецФункции

Функция ДобавитьКолонкиТаблицыПоОбразцу(ТаблицаПриемник, ТаблицаОбразец) Экспорт
	Для каждого Элем Из ТаблицаОбразец.Колонки Цикл
		Если ТаблицаПриемник.Колонки.Найти(Элем.Имя) = Неопределено Тогда
			ТаблицаПриемник.Колонки.Добавить(Элем.Имя, Элем.ТипЗначения);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Истина;
КонецФункции

Функция ОбъединитьТаблицы(ТаблицаПриемник, ТаблицаИсточник, ПолноеОбъединение = Ложь) Экспорт
	// добавим колонки из источника
	Если ПолноеОбъединение Тогда
		Для каждого Элем Из ТаблицаИсточник.Колонки Цикл
			Если ТаблицаПриемник.Колонки.Найти(Элем.Имя) = Неопределено Тогда
				ТаблицаПриемник.Колонки.Добавить(Элем.Имя, Элем.ТипЗначения, Элем.Заголовок, Элем.Ширина);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	// добавим данные из источника
	Для каждого строкаИсточника Из ТаблицаИсточник Цикл
		ЗаполнитьЗначенияСвойств(ТаблицаПриемник.Добавить(), строкаИсточника);
	КонецЦикла;
	
	Возврат Истина;
КонецФункции

Функция ЗагрузитьТаблицуЗначений(ТаблицаПриемник, ТаблицаИсточник, ОчиститьПередЗагрузкой = Ложь) Экспорт
	Если ОчиститьПередЗагрузкой Тогда
		ТаблицаПриемник.Очистить();
	КонецЕсли;
	
	Для каждого Стр Из ТаблицаИсточник Цикл
		ЗаполнитьЗначенияСвойств(ТаблицаПриемник.Добавить(), Стр);
	КонецЦикла;
	
	Возврат Истина;
КонецФункции

Функция СреднееЗначениеПоКолонке(Таблица, ИмяКолонки) Экспорт
	ЧислоЗаписей = Таблица.Количество();
	
	Если ЧислоЗаписей = 0 Тогда
		Возврат 0;
	Иначе
		Возврат Таблица.Итог(ИмяКолонки) / ЧислоЗаписей;
	КонецЕсли;
КонецФункции

#КонецОбласти

Функция СформироватьПараметрыЗапускаВнешнейОбработки(пИмя) Экспорт
	пСтруктура = Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Вид", Перечисления.ВидыДополнительныхОтчетовИОбработок.ДополнительнаяОбработка);
	Запрос.УстановитьПараметр("ИмяОбъекта", пИмя);
	
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ДополнительныеОтчетыИОбработки.Ссылка КАК Ссылка,
	|	ДополнительныеОтчетыИОбработки.Наименование КАК Наименование
	|ИЗ
	|	Справочник.ДополнительныеОтчетыИОбработки КАК ДополнительныеОтчетыИОбработки
	|ГДЕ
	|	ДополнительныеОтчетыИОбработки.Вид = &Вид
	|	И ДополнительныеОтчетыИОбработки.ИмяОбъекта = &ИмяОбъекта";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		пСтруктура = Новый Структура;
		пСтруктура.Вставить("Ссылка", Выборка.Ссылка);
		пСтруктура.Вставить("ЭтоОтчет", Ложь);
		пСтруктура.Вставить("Представление", Выборка.Наименование);
		пСтруктура.Вставить("Идентификатор", "ВнешняяОбработка." + пИмя);
	КонецЕсли;
	
	Возврат пСтруктура;
КонецФункции

// Галфинд (Гуру/Картэкс) Биматов 2019/05/07 (
// Требование ФТД ОС МСФО
//
// Устанавливает свойства элемента формы на основании переданного образца.
//
// Параметры:
//  НовыйЭлемент - ПолеФормы - элемент формы, для которого требуется установить свойства.
//  ОпорныйЭлемент - ПолеФормы - элемент формы, на основании свойств которого устанавливаются свойства.
Процедура СкопироватьСвойства_ПолеВвода(НовыйЭлемент, ОпорныйЭлемент) Экспорт
	
	// Не копирую поля - Имя, Родитель, ПутьКДанным, ПутьКДаннымПодвала
	
	ПоляКопирования = 
	// Общие свойства для любого ПоляФормы:
	"АвтоВысотаЯчейки, АктивизироватьПоУмолчанию, ВертикальноеПоложение, Вид, 
	|Видимость,ВысотаЗаголовка, ГиперссылкаЯчейки, 
	|ГоризонтальноеПоложение, ГоризонтальноеПоложениеВПодвале, ГоризонтальноеПоложениеВШапке, Доступность, Заголовок,
	|КартинкаПодвала, КартинкаШапки, ОграничениеТипа, ОтображатьВПодвале, ОтображатьВШапке,
	|ОтображениеПредупрежденияПриРедактировании, Подсказка, ПоложениеЗаголовка, ПредупреждениеПриРедактировании,
	|ПропускатьПриВводе, РежимРедактирования, СочетаниеКлавиш, ТекстПодвала, ТолькоПросмотр, ФиксацияВТаблице,
	|ЦветТекстаЗаголовка, ЦветТекстаПодвала, ЦветФонаЗаголовка, ЦветФонаПодвала, ШрифтЗаголовка, ШрифтПодвала,
	// Свойства расширения ПоляВвода:
	|АвтоВыборНезаполненного, АвтоОтметкаНезаполненного, БыстрыйВыбор, 
	|ВыделятьОтрицательные, Высота, ВысотаСпискаВыбора, 
	|РастягиватьПоВертикали, РастягиватьПоГоризонтали,
	|Формат, ЦветТекста, 
	|ЦветФона, Ширина, Шрифт";
	
	СтруктураПолейКопирования = Новый Структура(ПоляКопирования);
	Для каждого эл Из СтруктураПолейКопирования Цикл
		Попытка
			НовыйЭлемент[эл.Ключ] = ОпорныйЭлемент[эл.Ключ];
		Исключение
			ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			ТекстОперации = НСтр("ru = 'Выполнение операции копирования свойств'");
			ЗаписьЖурналаРегистрации(ТекстОперации,
			УровеньЖурналаРегистрации.Ошибка, , , 
			ПодробноеПредставлениеОшибки);
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры // Галфинд (Гуру/Картэкс) Биматов 2019/05/07 )

// Галфинд (Гуру/Картэкс) Биматов 2019/05/07 (
// Требование ФТД ОС МСФО
//
// Определяет длину временного интервала в месяцах.
//
// Параметры:
//   ДатаБольшая - Дата - дата начала интервала, более ранняя.
//   ДатаМалая - Дата - дата окончания интервала, более поздняя.
//
// Возвращаемое значение:
//   Число - разница в полных месяцах.
Функция РазностьМесяцев(ДатаБольшая, ДатаМалая) Экспорт
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	РАЗНОСТЬДАТ(&ДатаМалая, &ДатаБольшая, МЕСЯЦ) КАК Разность");
	Запрос.УстановитьПараметр("ДатаБольшая", ДатаБольшая);
	Запрос.УстановитьПараметр("ДатаМалая", ДатаМалая);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Разность;
	Иначе
		Возврат 0;
	КонецЕсли;
	
КонецФункции // Галфинд (Гуру/Картэкс) Биматов 2019/05/07 )

// Галфинд (Гуру/Картэкс) Биматов 2019/05/07 (
// Требование ФТД ОС МСФО
//
// Формирует сообщение пользователю.
//
// Параметры:
//  Текст - Строка - текст сообщения пользователю.
//
Процедура СообщитьСервер(Текст) Экспорт
	Со = Новый СообщениеПользователю;
	Со.Текст = Текст;
	Со.Сообщить();
КонецПроцедуры // Галфинд (Гуру/Картэкс) Биматов 2019/05/07 )

Процедура гф_УстановкаПараметровСеанса(ИменаПараметровСеанса) Экспорт
	Если ИменаПараметровСеанса <> Неопределено 
		И ИменаПараметровСеанса.Найти("гф_Организации_ОтдельныйРасчетВыпуска") <> Неопределено Тогда
		МассивОрганизаций = Новый Массив;
		тОрганизация = ПолучитьГлобальноеЗначение("РасчетЗатратНаВыпускОтдельнымДокументом");
		Если ЗначениеЗаполнено(тОрганизация) Тогда
			МассивОрганизаций.Добавить(тОрганизация);
		КонецЕсли;
		тОрганизация_Массив = ПолучитьГлобальноеЗначениеМассив("РасчетЗатратНаВыпускОтдельнымДокументом");
		Для каждого тОрганизация Из тОрганизация_Массив Цикл
			МассивОрганизаций.Добавить(тОрганизация);
		КонецЦикла; 
		
		ПараметрыСеанса.гф_Организации_ОтдельныйРасчетВыпуска = Новый ФиксированныйМассив(МассивОрганизаций);		
	КонецЕсли;
КонецПроцедуры

// vvv Галфинд \ Sakovich 28.12.2022
Процедура гф_ПаузаНаСервере(ИнтервалОжидания = 1) Экспорт
	//БСП 3.1.5
	ПараметрыЗапуска = ФайловаяСистема.ПараметрыЗапускаПрограммы();
	ПараметрыЗапуска.ДождатьсяЗавершения = Истина;
	ФайловаяСистема.ЗапуститьПрограмму("timeout /t " + Формат(ИнтервалОжидания, "ЧГ=0"), ПараметрыЗапуска);
КонецПроцедуры // ^^^ Галфинд \ Sakovich 28.12.2022 

#КонецОбласти