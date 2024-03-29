﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
КонецПроцедуры

#КонецОбласти 

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Загрузить(Команда) 
	// #wortmann { 
	// Процедура помещения файлов из выбранного каталога
	// Галфинд_Домнышева 2022/09/19	
	МассивПапокЗагрузки = Новый Массив;
	СтруктураПапокОрганизаций = Новый Структура;
	
	Если Не ЗначениеЗаполнено(Объект.КаталогЗагрузки) Тогда
		МассивПапокЗагрузки = ПолучитьМассивПапокОрганизаций();
	Иначе
		Если Не ЗначениеЗаполнено(Объект.Организация) Тогда
			 ОбщегоНазначенияКлиентСервер.СообщитьПользователю("При ручном выборе каталога должна быть заполнена Организация");
			 Возврат;
		КонецЕсли;
		Элт = Новый Структура("Организация, Каталог, Архив", 
							Объект.Организация, Объект.КаталогЗагрузки, Объект.КаталогЗагрузки + "\Loaded\"); 
		МассивПапокЗагрузки.Добавить(Элт);
	КонецЕсли;
	
	Для каждого Строка Из МассивПапокЗагрузки Цикл 
		
		Организация = Строка.Организация;
		Архив = Строка.Архив;
		МассивФайлов = НайтиФайлы(Строка.Каталог, "*.xml");		
		ОписанияПередаваемыхФайлов = Новый Массив;
		
		Если МассивФайлов.Количество() <> 0 Тогда
			
			Для каждого Элемент Из МассивФайлов Цикл		 
				
				
				
				Описание = Новый ОписаниеПередаваемогоФайла;
				Описание.Имя = Элемент.ПолноеИмя; 
				ОписанияПередаваемыхФайлов.Добавить(Описание);
			КонецЦикла;
			
			ДополнительныеПараметры = Новый Структура("Организация, Архив", Организация, Архив);
			
			ОписаниеОЗавершении = Новый ОписаниеОповещения("ОбработатьВыборВнешнегоФайла", ЭтотОбъект, ДополнительныеПараметры);
			НачатьПомещениеФайловНаСервер(ОписаниеОЗавершении, , , ОписанияПередаваемыхФайлов, 
			ЭтотОбъект.УникальныйИдентификатор);
			
		КонецЕсли;
										
	КонецЦикла;
	// } #wortmann
КонецПроцедуры  

#КонецОбласти 

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура КаталогЗагрузкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	// #wortmann { 
	// Открытие диалога выбора папки при ручном выборе КаталогаЗагрузки
	// Галфинд_Домнышева 2022/09/19
	Режим = РежимДиалогаВыбораФайла.ВыборКаталога; 
	Диалог = Новый ДиалогВыбораФайла(Режим); 
	Диалог.Каталог = ""; 
	Диалог.МножественныйВыбор = Ложь; 
	Диалог.Заголовок = "Выберите каталог"; 
	Если Диалог.Выбрать() Тогда 
		Объект.КаталогЗагрузки = Диалог.Каталог;
	КонецЕсли;
	// } #wortmann
КонецПроцедуры

#КонецОбласти 

 #Область СлужебныеПроцедурыИФункции
// #wortmann { 
// Производит вызов процедуры для загрузки файлов из i5 и возвращает массив загруженных файлов. 
// Галфинд_Домнышева 2022/09/19
// 
// Параметры:
//	ДанныеДляЗагрузки - Массив - массив структур с данными загружаемых файлов.
//
// Возвращаемое значение:
//	ФайлыВАрхив - Массив - массив состоящий из значений ПолногоИмениФайла.
//	КаталогАрхива - Строка - Путь к Папке для архивации файлов
&НаСервере
Функция ЗагрузитьНаСервере(ДанныеДляЗагрузки, КаталогАрхива)	
	
	ФайлыВАрхив = Новый Массив;
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	ФайлыВАрхив = ДокументОбъект.ВыполнитьОбменДанными(ДанныеДляЗагрузки, КаталогАрхива);
	Возврат  ФайлыВАрхив;
	
КонецФункции// } #wortmann

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
	
	ФайлыВАрхив = Новый Массив;
	МассивИнтерфейсов = ПолучитьСтроковыеЗначенияМассиваИнтерфейсов(); // Галфинд_Домнышева_22_01_2024

	ДанныеДляЗагрузки = Новый Массив;
	Для каждого Элемент Из ПомещенныеФайлы Цикл 
		// ++ Галфинд_Домнышева_22_01_2024
		ПродолжаемЗагрузку = Ложь;
		Для каждого Стр Из МассивИнтерфейсов Цикл
			Если СтрЧислоВхождений(ВРег(Элемент.СсылкаНафайл.Файл.Имя), Стр) > 0 Тогда
				ПродолжаемЗагрузку = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		Если ПродолжаемЗагрузку Тогда
		// -- Галфинд_Домнышева_22_01_2024
		
		////++ Галфинд_Домнышева_18-10-2023
		//Если СтрЧислоВхождений(ВРег(Элемент.СсылкаНафайл.Файл.Имя), "PRICAT") > 0 
		//	ИЛИ СтрЧислоВхождений(ВРег(Элемент.СсылкаНафайл.Файл.Имя), "ORDRSP") > 0  Тогда
		////-- Галфинд_Домнышева_18-10-2023
		
		//++ Галфинд_Домнышева_21-03-2023
		// Проверка загружен ли файл уже в базу
		Если ФайлЗагруженРанее(Элемент.СсылкаНафайл.Файл.Имя) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Файл " + Элемент.СсылкаНафайл.Файл.Имя + " загружен в систему ранее");
			Продолжить;
		КонецЕсли;
		//-- Галфинд_Домнышева_21-03-2023
		НовыйЭлемент = Новый Структура("Адрес, ИмяФайла, ПолноеИмяФайла, Организация");
		НовыйЭлемент.Адрес = Элемент.Адрес;
		НовыйЭлемент.ИмяФайла = Элемент.СсылкаНафайл.Файл.Имя;
		НовыйЭлемент.ПолноеИмяФайла = Элемент.СсылкаНафайл.Файл.ПолноеИмя;
		НовыйЭлемент.Организация = ДополнительныеПараметры.Организация;
		ДанныеДляЗагрузки.Добавить(НовыйЭлемент);
		//++ Галфинд_Домнышева_18-10-2023	
		Иначе
			Продолжить;
		КонецЕсли;
		//-- Галфинд_Домнышева_18-10-2023
	КонецЦикла;
	
	ФайлыВАрхив = ЗагрузитьНаСервере(ДанныеДляЗагрузки, ДополнительныеПараметры.Архив);
	Если ФайлыВАрхив.Количество() > 0 Тогда
		ЗаписатьВАрхивУдалитьИзКаталога(ФайлыВАрхив, ДополнительныеПараметры.Архив);
		// ++ Галфинд_ДомнышеваКР_11_12_2023
		ОбработатьСозданныеДокументы(ФайлыВАрхив);
		// -- Галфинд_ДомнышеваКР_11_12_2023
	КонецЕсли;
	
КонецПроцедуры// } #wortmann

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
	СоздатьКаталог(КудаКопируем);
	
	КаталогЗагруженных = Новый Файл(КудаКопируем);
	Если Не КаталогЗагруженных.Существует() Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Каталог для загруженных файлов задан неверно или не существует...");
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	Для каждого Файл Из ФайлыВАрхив Цикл
		ПереместитьФайл(Файл.ПолноеИмя, КудаКопируем + "\" + Файл.Имя);
	КонецЦикла;
	
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
		|	гф_КаталогиОбработкиФайловXML.Организация КАК Организация,
		|	гф_КаталогиОбработкиФайловXML.Источник КАК Каталог,
		|	гф_КаталогиОбработкиФайловXML.Архив КАК Архив
		|ИЗ
		|	Справочник.гф_КаталогиОбработкиФайловXML КАК гф_КаталогиОбработкиФайловXML";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		 Элт = Новый Структура("Организация, Каталог, Архив");
		 ЗаполнитьЗначенияСвойств(Элт, Выборка);
		 МассивПапокЗагрузки.Добавить(Элт);
	КонецЦикла;
	
	Возврат МассивПапокЗагрузки;
	
КонецФункции// } #wortmann  

// #wortmann { 
// Функция проверяет загружался ли файл ранее 
// Галфинд_Домнышева 2023/03/21
//
// Параметры:
//  Элемент - Файл.
//
// Возвращаемое значение:
// Булево - Истина, если файл загружен удачно ранее, иначе Ложь
//
&НаСервере
Функция ФайлЗагруженРанее(Имя) 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	гф_ДанныеЗагрузки.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.гф_ДанныеЗагрузки КАК гф_ДанныеЗагрузки
		|ГДЕ
		|	гф_ДанныеЗагрузки.ИмяФайла ПОДОБНО &ИмяФайла
		|	И гф_ДанныеЗагрузки.Проведен = Истина";
	
	Запрос.УстановитьПараметр("ИмяФайла", Имя);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции// } #wortmann

// #wortmann { 
// Процедура по разбору ранее созданных документов 
// Галфинд_Домнышева 2023/12/12
//
// Параметры:
//  ФайлыВАрхив - Массив - массивструктур имен файлов
//
&НаСервере
Процедура ОбработатьСозданныеДокументы(ФайлыВАрхив)
	
	МасивИмен = Новый Массив;
	Для каждого Стр Из ФайлыВАрхив Цикл
		МасивИмен.Добавить(Стр.ПолноеИмя);
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"
		|ВЫБРАТЬ
		|	гф_ДанныеЗагрузки.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.гф_ДанныеЗагрузки КАК гф_ДанныеЗагрузки
		|ГДЕ
		|	НЕ гф_ДанныеЗагрузки.Проведен
		|   И ВЫРАЗИТЬ(гф_ДанныеЗагрузки.ПолноеИмяФайла КАК Строка(200)) В (&МасивИмен)
		|
		|";
	
	Запрос.УстановитьПараметр("МасивИмен", МасивИмен);
	РезультатЗапроса = Запрос.Выполнить();
	СозданныеДокументы = РезультатЗапроса.Выгрузить().ВыгрузитьКолонку("Ссылка");
	
    ДокументОбъект = РеквизитФормыВЗначение("Объект");
	ДокументОбъект.ОбработкаСозданныхДокументов(СозданныеДокументы);
	
КонецПроцедуры// } #wortmann 

// #wortmann { 
// Процедура по получению и разбору массива Интерфейса
// Галфинд_ДомнышеваКР_22_01_2024
&НаСервере
Функция ПолучитьСтроковыеЗначенияМассиваИнтерфейсов()
	
	МассивИнтерфейсов = _омОбщегоНазначенияВызовСервера.ПолучитьГлобальноеЗначениеМассив("гф_ИнтерфейсыДляОбработкиИ5");
	НовыйМассив = Новый Массив;
	
	Для каждого Интерфейс Из МассивИнтерфейсов Цикл 
		Если Интерфейс = Перечисления.гф_Интерфейсы.PRICAT Тогда
			НовыйМассив.Добавить("PRICAT_");
			Продолжить;
		КонецЕсли;
		// ++ Галфинд_ДомнышеваКР_06_02_2024
		// Синоним у интерфейса отличается от строковой надписи в имени файла
		Если Интерфейс = Перечисления.гф_Интерфейсы.PRICAT_SORT Тогда
			НовыйМассив.Добавить("PRICATSORT");
			Продолжить;
		КонецЕсли;
        // -- Галфинд_ДомнышеваКР_06_02_2024
		НовыйМассив.Добавить(Строка(Интерфейс));
	КонецЦикла;	

    Возврат НовыйМассив;
КонецФункции// } #wortmann

#КонецОбласти