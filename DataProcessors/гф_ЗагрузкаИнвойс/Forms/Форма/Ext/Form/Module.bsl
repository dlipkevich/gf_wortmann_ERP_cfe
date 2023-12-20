﻿
&НаКлиенте
Процедура КаталогЗагрузкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка) 
	
	СтандартнаяОбработка=ложь;
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	Диалог.Заголовок = "Выберите каталог файлов загрузки";
	Диалог.ПолноеИмяФайла = ""; 	 
	Диалог.МножественныйВыбор = Ложь;
	
	Если Диалог.Выбрать() Тогда
		Объект.КаталогЗагрузки = Диалог.Каталог;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьДанные(Команда) 
	
	Объект.СозданныеДокументы.Очистить();
	
	МассивПапокЗагрузки = Новый Массив;
	
	Если Не ЗначениеЗаполнено(Объект.КаталогЗагрузки) Тогда
		МассивПапокЗагрузки = ПолучитьМассивПапокОрганизаций();
	Иначе
		Элт = Новый Структура("Каталог, Архив, Логи", Объект.КаталогЗагрузки, Объект.КаталогЗагрузки + "\Loaded\",
								Объект.КаталогЗагрузки + "\Logs\"); 
		МассивПапокЗагрузки.Добавить(Элт);
	КонецЕсли;
	
	Для каждого Строка Из МассивПапокЗагрузки Цикл 
		
		Архив = Строка.Архив;
		Логи = Строка.Логи;
		МассивФайлов = НайтиФайлы(Строка.Каталог, "*.xml");		
		ОписанияПередаваемыхФайлов = Новый Массив;
		
		МассивФайлов = ПреобразоватьМассив(МассивФайлов); 
		
		Если МассивФайлов.Количество() < 2  Тогда
			
			Сообщить("Файлы не обнаружены.");
			Продолжить;
		КонецЕсли;
		
		Для каждого Элемент Из МассивФайлов Цикл		 
			Описание = Новый ОписаниеПередаваемогоФайла;
			Описание.Имя = Элемент.ПолноеИмя; 
			ОписанияПередаваемыхФайлов.Добавить(Описание);
		КонецЦикла;
		
		ДополнительныеПараметры = Новый Структура("Архив, Логи", Архив, Логи);
		
		ОписаниеОЗавершении = Новый ОписаниеОповещения("ОбработатьВыборВнешнегоФайла", ЭтотОбъект, ДополнительныеПараметры);
		НачатьПомещениеФайловНаСервер(ОписаниеОЗавершении, , , ОписанияПередаваемыхФайлов, 
		ЭтотОбъект.УникальныйИдентификатор);
										
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ЗагрузитьДанныеНаСервере(ФайлыЗагрузки, Архив, Логи)
		
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ФайлыВАрхив = ОбработкаОбъект.ВыполнитьОбменДанными(ФайлыЗагрузки, Архив, Логи);
		
	ЗначениеВДанныеФормы(ОбработкаОбъект.СозданныеДокументы,Объект.СозданныеДокументы); 
	
	Возврат ФайлыВАрхив;
КонецФункции

// #wortmann { 
// Формирует Массив структур с данными помещенных файлов и при получении
// массива архивируемых файлов вызывает процедуру ЗаписатьВАрхивУдалитьИзКаталога() 
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
// ПомещенныеФайлы - значение результата, переданное вторым параметром при вызове метода,
// ДополнительныеПараметры - значение, которое было указано при создании объекта оповещения.
//
&НаКлиенте
Процедура ОбработатьВыборВнешнегоФайла(ПомещенныеФайлы, ДополнительныеПараметры) Экспорт
	
	ДанныеДляЗагрузки = Новый Массив;
	Для каждого Элемент Из ПомещенныеФайлы Цикл
		НовыйЭлемент = Новый Структура("Адрес, ИмяФайла, ПолноеИмя, ИмяБезРасширения");
		НовыйЭлемент.Адрес = Элемент.Адрес;
		НовыйЭлемент.ИмяФайла = Элемент.СсылкаНафайл.Файл.Имя;
		НовыйЭлемент.ПолноеИмя = Элемент.СсылкаНафайл.Файл.ПолноеИмя;
		НовыйЭлемент.ИмяБезРасширения = Элемент.СсылкаНафайл.Файл.ИмяБезРасширения;
		ДанныеДляЗагрузки.Добавить(НовыйЭлемент);
	КонецЦикла;
	
	ФайлыВАрхив = ЗагрузитьДанныеНаСервере(ДанныеДляЗагрузки, ДополнительныеПараметры.Архив, ДополнительныеПараметры.Логи);
	
	Если ФайлыВАрхив.Количество() > 0 Тогда
		ЗаписатьВАрхивУдалитьИзКаталога(ФайлыВАрхив, ДополнительныеПараметры.Архив);
	КонецЕсли; 

	// ++ Галфинд СадомцевСА 05.12.2023
	ВыполнитьОбработкаЗаказовНаЭмиссиюКМ();
	// -- Галфинд СадомцевСА 05.12.2023
	
КонецПроцедуры// } #wortmann

// #wortmann { 
// Выгружает данные из справочника гф_КаталогиОбработкиФайловXML
// Галфинд_Домнышева 2022/12/21
//
// Возвращаемое значение:
//	МассивПапокЗагрузки - Массив структур с ключами "Организация, Каталог, Архив"
&НаСервере
Функция ПолучитьМассивПапокОрганизаций() 
	
	МассивПапокЗагрузки = Новый Массив; 

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	гф_КаталогиОбработкиФайловXML.Логи КАК Логи,
		|	гф_КаталогиОбработкиФайловXML.Источник КАК Каталог,
		|	гф_КаталогиОбработкиФайловXML.Архив КАК Архив
		|ИЗ
		|	Справочник.гф_КаталогиОбработкиФайловXML КАК гф_КаталогиОбработкиФайловXML";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		 Элт = Новый Структура("Каталог, Архив, Логи");
		 ЗаполнитьЗначенияСвойств(Элт, Выборка);
		 МассивПапокЗагрузки.Добавить(Элт);
	КонецЦикла;
	
	Возврат МассивПапокЗагрузки;
	
КонецФункции  

// #wortmann { 
// Создает каталог по дате загрузки и перемещает загруженные файлы из родительского каталога в созданный.  
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
// ФайлыВАрхив - Массив - массив файлов для помещения в архив
// КаталогАрхива - Строка - Путь к Папке для архивации файлов
&НаКлиенте
Процедура ЗаписатьВАрхивУдалитьИзКаталога(ФайлыВАрхив, КаталогАрхива) 
	
	ДатаАрхивации = ОбщегоНазначенияКлиент.ДатаСеанса();
	ДатаАрхивации = Формат(ДатаАрхивации, "ДФ = ггггММдд");
	КудаКопируем = КаталогАрхива + "\" + ДатаАрхивации;               
	
	КаталогНаДиске = Новый Файл(КудаКопируем);
	Если НЕ КаталогНаДиске.Существует() Тогда
		СоздатьКаталог(КудаКопируем);
	КонецЕсли;
	
	КаталогЗагруженных = Новый Файл(КудаКопируем);
	Если Не КаталогЗагруженных.Существует() Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Каталог для загруженных файлов задан неверно или не существует...");
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	Для каждого Файл Из ФайлыВАрхив Цикл
		ПереместитьФайл(Файл.ПолноеИмя, КудаКопируем + "\" + Файл.Имя + ".xml");
	КонецЦикла;
	
КонецПроцедуры// } #wortmann  

&НаКлиенте
Функция ПреобразоватьМассив(МассивФайлов)
	
	НовыйМассивФайлов = Новый Массив;
	Для каждого Эл Из МассивФайлов Цикл
		Если СтрНайти(Эл.Имя, "shippinglist") > 0
			ИЛИ СтрНайти(Эл.Имя, "InvoiceAusgehend_V") > 0 Тогда
			НовыйМассивФайлов.Добавить(Эл);
		КонецЕсли;
	КонецЦикла;
	Возврат НовыйМассивФайлов;
	
КонецФункции

&НаСервере
Процедура ВыполнитьОбработкаЗаказовНаЭмиссиюКМ()
	// ++ Галфинд СадомцевСА 05.12.2023 Функционал скопирован
	// Из регл. задания регл. задание гф_ЗагрузкаИнвойс (Загрузка файлов инвойс и шиппинг лист)
	// В обработку гф_ЗагрузкаИнвойс (Загрузка Invoice и Shipping List)
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee8e86656e3f52
	Попытка
		СтрокаСообщения = "ЗапускОбработкиСозданияЭмиссииКМ.СтартОбработки";
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(СтрокаСообщения);
		ОбработкаЗапуска = Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ.Создать();
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(СтрокаСообщения);
		Возврат;
	КонецПопытки;
	
	Попытка
// Галфинд_Окунев 2023.12.20 {
		Отбор = Новый Структура;
		Отбор.Вставить("ЭтоРоялти", Ложь);
		ТЗ_ПТУ = Объект.СозданныеДокументы.Выгрузить(Отбор, "Документ"); 
		МассивПТУ = ТЗ_ПТУ.ВыгрузитьКолонку("Документ");
// Галфинд_Окунев 2023.12.20 }
		ОбработкаЗапуска.ПроверитьУстановитьСтатусыКМЭмитированы(Истина, МассивПТУ);
		СтрокаСообщения = "ЗапускОбработкиСозданияЭмиссииКМ.ФинишОбработки";
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(СтрокаСообщения);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		СтрокаСообщения = "Ошибка при запуске обработки: " + ТекстОшибки;
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(СтрокаСообщения);
		Возврат;
	КонецПопытки;
	// -- Галфинд СадомцевСА 05.12.2023
КонецПроцедуры
