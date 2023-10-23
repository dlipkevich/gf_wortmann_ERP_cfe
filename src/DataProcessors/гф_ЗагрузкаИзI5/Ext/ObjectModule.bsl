﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

Перем СозданныеДокументы; // Массив создаваемых документов гф_ДанныеЗагрузки.
Перем ЗагружаемыеПоля; // ТЗ с полученными данными из справочника гф_НастройкаЗагружаемыхДанных.

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// #wortmann { 
// Процедура служит для вызова загрузки из Регламентного задания  
// Галфинд_Домнышева 2022/12/29
Процедура ВыполнитьЗагрузкуИРазборФайлов() Экспорт 
	
		МассивПапокЗагрузки = ПолучитьМассивПапокОрганизаций();
	
	Для каждого Строка Из МассивПапокЗагрузки Цикл 
		
		Архив = Строка.Архив;
		МассивФайлов = НайтиФайлы(Строка.Каталог, "*.xml");		
		ДанныеДляЗагрузки = Новый Массив;
		Организация = Строка.Организация;
		
		
		Если МассивФайлов.Количество() > 0 Тогда
			
			Для каждого Элемент Из МассивФайлов Цикл 
				//++ Галфинд_Домнышева_18-10-2023
				Если СтрЧислоВхождений(ВРег(Элемент.Имя), "PRICAT") > 0 
					ИЛИ СтрЧислоВхождений(ВРег(Элемент.Имя), "ORDRSP") > 0  Тогда
                //-- Галфинд_Домнышева_18-10-2023
				
				// Проверка загружен ли файл уже в базу
				Если ФайлЗагруженРанее(Элемент) Тогда
					Сообщение = "Файл " + Элемент + " загружен в систему ранее" ;
					ЗаписьЖурналаРегистрации("Информация", УровеньЖурналаРегистрации.Информация, ЭтотОбъект, ЭтотОбъект, Сообщение);
					Продолжить;
				КонецЕсли;
				
				НовыйЭлемент = Новый Структура("Адрес, ИмяФайла, ПолноеИмяФайла, Организация");
				НовыйЭлемент.ИмяФайла = Элемент.Имя;
				НовыйЭлемент.ПолноеИмяФайла = Элемент.ПолноеИмя;
				НовыйЭлемент.Организация = Организация;
				ДанныеДляЗагрузки.Добавить(НовыйЭлемент); 
				//++ Галфинд_Домнышева_18-10-2023	
				Иначе
					Продолжить;
				КонецЕсли;
				//-- Галфинд_Домнышева_18-10-2023
			КонецЦикла;
			
			ФайлыВАрхив = ВыполнитьОбменДанными(ДанныеДляЗагрузки, Архив);

			Если ФайлыВАрхив.Количество() > 0 Тогда
				ЗаписатьВАрхивУдалитьИзКаталога(ФайлыВАрхив, Архив);
			КонецЕсли;	

		Иначе
			Сообщение = "В каталоге " + Строка.Каталог + " нет файлов с расширением .XML" ;
			ЗаписьЖурналаРегистрации("Информация", УровеньЖурналаРегистрации.Информация, ЭтотОбъект, ЭтотОбъект, Сообщение);
		КонецЕсли; 		
				
	КонецЦикла;
	
КонецПроцедуры 

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
Функция ФайлЗагруженРанее(Элемент) 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	гф_ДанныеЗагрузки.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.гф_ДанныеЗагрузки КАК гф_ДанныеЗагрузки
		|ГДЕ
		|	гф_ДанныеЗагрузки.ИмяФайла ПОДОБНО &ИмяФайла
		|	И гф_ДанныеЗагрузки.Проведен = Истина";
	
	Запрос.УстановитьПараметр("ИмяФайла", Элемент.Имя);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

// #wortmann { 
// Экспортная функция по загрузке полученных файлов 
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
//  МассивЗагружаемыхФайлов - Массив - Массив полученных файлов из I5.
//
// Возвращаемое значение:
// МассивФайловДляАрхивации - Массив - Массив успешно загруженных файлов для их дальнейшей архивации.
//
Функция ВыполнитьОбменДанными(МассивЗагружаемыхФайлов, КаталогАрхива) Экспорт
	
	СозданныеДокументы = Новый Массив;
	МассивФайловДляАрхивации = Новый Массив;

	Если МассивЗагружаемыхФайлов.Количество() > 0 Тогда
		Для каждого ФайлОбмена Из МассивЗагружаемыхФайлов Цикл
			Сообщение = Строка(ТекущаяДатаСеанса()) + " Начало загрузки файла " + ФайлОбмена.ИмяФайла;
			ЗагрузитьФайл(ФайлОбмена);
		КонецЦикла;
	КонецЕсли;

	// Доработка для последовательной загрузки включая ранее не проведенные документы!
	УпорядочитьПоИнтерфейсам(СозданныеДокументы);
	
	Интерфейсы = Новый Массив;
	Интерфейсы.Добавить(Перечисления.гф_Интерфейсы.ORDRSP);
	Интерфейсы.Добавить(Перечисления.гф_Интерфейсы.INVOICE);
	Интерфейсы.Добавить(Перечисления.гф_Интерфейсы.IС_INVOICE);
	Интерфейсы.Добавить(Перечисления.гф_Интерфейсы.SHIPPING_LIST);
	Интерфейсы.Добавить(Перечисления.гф_Интерфейсы.PRICAT_SORT);
	
	Для Каждого СозданныйДокумент Из СозданныеДокументы Цикл
		
		Попытка
			ДокументДанные = СозданныйДокумент.ПолучитьОбъект();
			
			// (н)Галфинд Домнышева 2023/01/18
			СтруктураДляАрхива = Новый Структура("Имя, ПолноеИмя");
			СтруктураДляАрхива.Имя = ДокументДанные.ИмяФайла;
			СтруктураДляАрхива.ПолноеИмя = ДокументДанные.ПолноеИмяФайла;
			// (к)Галфинд Домнышева 2023/01/18
			
			Если ДокументДанные.Интерфейс = Перечисления.гф_Интерфейсы.PRICAT Тогда
				ДокументДанные.СоздатьНоменклатуру();
				Если ДокументДанные.СтатусДокумента = Перечисления.гф_СтатусыДокументовЗагрузки.НоменклатураЗагружена Тогда
					ДокументДанные.СоздатьНоменклатуру(, Ложь, Истина);
				//КонецЕсли;
				ДокументДанные.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
				// (н)Галфинд Домнышева 2023/08/29	
				Иначе
					ДокументДанные.Записать(РежимЗаписиДокумента.Запись);
				КонецЕсли;
                // (к)Галфинд Домнышева 2023/08/29
				//МассивФайловДляАрхивации.Добавить(ДокументДанные.ПолноеИмяФайла); 
				МассивФайловДляАрхивации.Добавить(СтруктураДляАрхива);// Галфинд Домнышева 2023/01/18
			ИначеЕсли Интерфейсы.Найти(ДокументДанные.Интерфейс) <> Неопределено Тогда			
				ДокументДанные.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
				//МассивФайловДляАрхивации.Добавить(ДокументДанные.ПолноеИмяФайла);
				МассивФайловДляАрхивации.Добавить(СтруктураДляАрхива);// Галфинд Домнышева 2023/01/18
			Иначе
				Сообщение = "Не задан интерфейс документа " + ДокументДанные;
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Формат(ТекущаяДатаСеанса(), "ДЛФ=T") + ". " + Сообщение);
			КонецЕсли;
			
			ЗаписатьОшибку(ДокументДанные);
		Исключение	
			ЗаписатьОшибку(ДокументДанные);
			СообщениеОбОшибке = "Произошли ошибки при проведении документа " + СозданныйДокумент + ".|" 
			+ ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			ЗаписьЖурналаРегистрации("Ошибка", УровеньЖурналаРегистрации.Ошибка, ЭтотОбъект, ЭтотОбъект, СообщениеОбОшибке);
		КонецПопытки;
		
	КонецЦикла;
	
	Возврат МассивФайловДляАрхивации; 
	
КонецФункции// } #wortmann

// #wortmann { 
// Процедура создает документ гф_ДанныеЗагрузки и РС гф_СтрокиДокументаДанныеЗагрузки  
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
//  ДанныеДляЗагрузки - Структура - данные файла из I5.
//
Процедура ЗагрузитьФайл(ДанныеДляЗагрузки)
	
	ДокументДанные = Документы.гф_ДанныеЗагрузки.СоздатьДокумент(); 
		
	ДокументДанные.СтатусДокумента = Перечисления.гф_СтатусыДокументовЗагрузки.НеЗагружено;
	ДокументДанные.Дата = ТекущаяДатаСеанса();
	ДокументДанные.ИмяФайла = ДанныеДляЗагрузки.ИмяФайла; 
	ДокументДанные.ПолноеИмяФайла = ДанныеДляЗагрузки.ПолноеИмяФайла;
	ДокументДанные.Организация = ДанныеДляЗагрузки.Организация;

	ДокументДанные.Записать(РежимЗаписиДокумента.Запись);
		
	НаборЗаписей = РегистрыСведений.гф_СтрокиДокументаДанныеЗагрузки.СоздатьНаборЗаписей();
	
	НаборЗаписей.Отбор.Документ.Установить(ДокументДанные.Ссылка);
	
	Если ЗначениеЗаполнено(ДанныеДляЗагрузки.Адрес) Тогда
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(ДанныеДляЗагрузки.Адрес);
		ИмяВременногоФайла = ПолучитьИмяВременногоФайла("xml"); 
		ДвоичныеДанные.Записать(ИмяВременногоФайла);	
	Иначе
		ИмяВременногоФайла = ДанныеДляЗагрузки.ПолноеИмяФайла;
	КонецЕсли;
	ЧтениеXML = Новый ЧтениеXML; 
	ЧтениеXML.ОткрытьФайл(ИмяВременногоФайла);
	
    // Заполнение полей строк документа (регистр сведений) информацией из информацией из XML
	
	НомерСтроки = 0;
	
	Пока ЧтениеXML.Прочитать() Цикл
		
		Если ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			
			Если ВРег(СокрЛП(ЧтениеXML.Имя)) = "PRICAT" Тогда
				ДокументДанные.Интерфейс = Перечисления.гф_Интерфейсы.PRICAT;
			ИначеЕсли ВРег(СокрЛП(ЧтениеXML.Имя)) = "ORDRSP" Тогда
				ДокументДанные.Интерфейс = Перечисления.гф_Интерфейсы.ORDRSP;
			ИначеЕсли ВРег(СокрЛП(ЧтениеXML.Имя)) = "INVOIC" Тогда
				ДокументДанные.Интерфейс = Перечисления.гф_Интерфейсы.INVOICE;
			ИначеЕсли ВРег(СокрЛП(ЧтениеXML.Имя)) = "SHIPPING_LIST" Тогда
				ДокументДанные.Интерфейс = Перечисления.гф_Интерфейсы.SHIPPING_LIST;
			Иначе
				Сообщение = Строка(ТекущаяДатаСеанса()) + " Не удалось определить тип интерфейса файла " 
							+ ДанныеДляЗагрузки.ИмяФайла + ". Настройки обмена в табличную часть не загружены!";
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
			КонецЕсли;	
	  
			Если ЗначениеЗаполнено(ДокументДанные.Интерфейс) Тогда 
				ЗагружаемыеПоля = ПолучитьЗагружаемыеПоля(ДокументДанные.Интерфейс);
			КонецЕсли;
     
 			ДокументДанные.Записать(РежимЗаписиДокумента.Запись);
						
			НомерСтроки = НомерСтроки + 1;
			НоваяСтрока = НаборЗаписей.Добавить();
			// BSLLS:Typo-off
			НоваяСтрока.Тэг = ЧтениеXML.Имя;
			// BSLLS:Typo-on
			НоваяСтрока.ПорядковыйНомерСтроки = НомерСтроки;
			НоваяСтрока.Документ = ДокументДанные.Ссылка;
			
			ЗагрузитьВетку(ЧтениеXML, НоваяСтрока, ДокументДанные, НаборЗаписей, НомерСтроки);
			
		КонецЕсли;
		
	КонецЦикла;

	Попытка
		НаборЗаписей.Записать();
	Исключение
		
		Сообщение = Строка(ТекущаяДатаСеанса()) + " Не удалось загрузить файл " + ДанныеДляЗагрузки.ИмяФайла
		+ " - ошибка записи в регистр сведений ""СтрокиДокументаДанныеЗагрузки""!";
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
		
		Возврат;
		
	КонецПопытки;
	
	ЧтениеXML.Закрыть();
	
	// Удаляем временный файл если загрузка с Клиента 
	Если ЗначениеЗаполнено(ДанныеДляЗагрузки.Адрес) Тогда
		
		Попытка
			УдалитьФайлы(ИмяВременногоФайла);
		Исключение
			ПодробноеПредставление = НСтр("ru = 'Не удалось удалить временный файл '")
			+ ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			ЗаписьЖурналаРегистрации("Ошибка", УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставление);
		КонецПопытки;
		
	КонецЕсли;
	
	// Заполнение полей строк документа (регистр сведений) информацией из настроек обмена
	ДокументДанные.СтатусДокумента = Перечисления.гф_СтатусыДокументовЗагрузки.Загружено;
	Попытка
		ДокументДанные.Записать(РежимЗаписиДокумента.Запись);
	Исключение
		Возврат;
	КонецПопытки;
	СозданныеДокументы.Добавить(ДокументДанные.Ссылка);       	
	
КонецПроцедуры// } #wortmann   

// #wortmann { 
// Процедура читает ветку XML файла и заполняет РС гф_СтрокиДокументаДанныеЗагрузки  
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
//  Файл - ЧтениеXML - файл из I5 из Временного Хранилища. 
//  Ветка - РегистрСведенийЗапись.гф_СтрокиДокументаДанныеЗагрузки - текущая строка (запись) в РС.
//  ДокОбъект - ДокументОбъект.гф_ДанныеЗагрузки - создаваемый документ гф_ДанныеЗагрузки.
//  НаборЗаписей - РегистрСведенийНаборЗаписей.гф_СтрокиДокументаДанныеЗагрузки. 
//  НомерСтроки - Число - номер строки.
//
Процедура ЗагрузитьВетку(Файл, Ветка, ДокОбъект, НаборЗаписей, НомерСтроки)
	// BSLLS:Typo-off
	Тэг = Файл.Имя;
	// BSLLS:Typo-on
	Родитель = Ветка;
	Пока Файл.Прочитать() Цикл
		// менять дату документа на дату из файла не требуется
		// BSLLS:Typo-off
		Если Файл.ТипУзла = ТипУзлаXML.КонецЭлемента И Файл.Имя = Тэг Тогда
		// BSLLS:Typo-on	
			Прервать;
		КонецЕсли;
		Если Файл.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			НомерСтроки = НомерСтроки + 1;
			НоваяСтрока = НаборЗаписей.Добавить();
			// BSLLS:Typo-off
			НоваяСтрока.Тэг = Файл.Имя;
			// BSLLS:Typo-on 
			НоваяСтрока.ПорядковыйНомерСтроки = НомерСтроки;
			НоваяСтрока.НомерСтрокиРодителя = Родитель.ПорядковыйНомерСтроки;
			НоваяСтрока.Документ = ДокОбъект.Ссылка;
			Если ЗначениеЗаполнено(ЗагружаемыеПоля) Тогда
				// BSLLS:Typo-off
				НайденноеЗначение = ЗагружаемыеПоля.Найти(НоваяСтрока.Тэг, "Наименование");
				// BSLLS:Typo-on
				Если НайденноеЗначение <> Неопределено Тогда
					НоваяСтрока.ПолеЗагрузки = НайденноеЗначение.Ссылка;
					НоваяСтрока.СтатусПоля = НайденноеЗначение.СтатусПоля;
				КонецЕсли;
			КонецЕсли;
			ЗагрузитьВетку(Файл, НоваяСтрока, ДокОбъект, НаборЗаписей, НомерСтроки);
		Иначе
			Ветка.Значение = Файл.Значение; 
			// ++ Галфинд_Домнышева_20_03_2023
			Если Тэг = "Document_date" Тогда
				 ДокОбъект.ДатаФайла = Дата(Файл.Значение);
			КонецЕсли;
			 // -- Галфинд_Домнышева_20_03_2023
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры// } #wortmann

// #wortmann { 
// Доработка для последовательной загрузки (проведения интерфейсов "по ранжиру") 
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
//  МассивДокументовДЗ - Массив - массив из созданных документов ДокументОбъект.гф_ДанныеЗагрузки.
//
Процедура УпорядочитьПоИнтерфейсам(МассивДокументовДЗ) 
	
	Если НЕ ТипЗнч(МассивДокументовДЗ) = Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	
	Интерфейсы	= Новый Соответствие();	
	Интерфейсы.Вставить("PRICAT", "PRICAT");
	Интерфейсы.Вставить("PRICAT_SORT", "PRICAT");
	Интерфейсы.Вставить("ORDRSP", "ORDRSP");
	
	// Сортировка массива документов по ранжиру интерфейсов
	МассивДокументовДЗ = ОтсортироватьМассивПоРанжиру(МассивДокументовДЗ, Интерфейсы);

КонецПроцедуры// } #wortmann	

// #wortmann { 
// Функция сортирует документы в массиве по "по ранжиру" интерфейсов 
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
//  МассивДокументовДЗ - Массив - массив из созданных документов ДокументОбъект.гф_ДанныеЗагрузки.
//  Интерфейсы - Соответствие - из названий интерфейсов.
//
// Возвращаемое значение:
// МассивДокументовПоРанжиру - Массив - массив из отсортированных документов ДокументОбъект.гф_ДанныеЗагрузки.
//
Функция ОтсортироватьМассивПоРанжиру(МассивДокументовДЗ, Интерфейсы) 
	
	МассивДокументовПоРанжиру	= Новый Массив;
	
	// Запрос для получения последовательности Интерфейсов для ранжирования документов
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	гф_ПоследовательностьПроведения.Интерфейс КАК Интерфейс
		|ИЗ
		|	Справочник.гф_ПоследовательностьПроведения КАК гф_ПоследовательностьПроведения
		|
		|УПОРЯДОЧИТЬ ПО
		|	гф_ПоследовательностьПроведения.ПорядокОбработки";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	// Массив документов ранжируется в порядке заданном выборкой
	Пока Выборка.Следующий() Цикл
		
		ТекущийИнтерфейсДокументаПоПриоритету	=  
				ПолучитьЗначениеПеречисленияИнтерфейсыПоИмени(Интерфейсы.Получить(СокрЛП(Выборка.Интерфейс)));
		// На всякий случай, если окажется что для такого интерфейса не было задано соответствие или не нашлось 
		// значение перечисления.
		Если ТекущийИнтерфейсДокументаПоПриоритету	= Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Если Выборка.Интерфейс = Перечисления.гф_Интерфейсы.PRICAT 
			ИЛИ Выборка.Интерфейс = Перечисления.гф_Интерфейсы.PRICAT_SORT Тогда
			// BSLLS:Typo-off
			МассивДокументовПрикат = ОтобратьДокументыПоИнтерфейсу(МассивДокументовДЗ, ТекущийИнтерфейсДокументаПоПриоритету);
			// BSLLS:Typo-on
		КонецЕсли;
		
		// Отбор документов для Pricat_Sort и Pricat осуществляется особым образом
		Если Выборка.Интерфейс = Перечисления.гф_Интерфейсы.PRICAT Тогда
			МассивДокументовПоТекущемуИнтерфейсу	= ОтобратьПрикат(МассивДокументовПрикат);
		ИначеЕсли Выборка.Интерфейс = Перечисления.гф_Интерфейсы.PRICAT_SORT Тогда
			МассивДокументовПоТекущемуИнтерфейсу	= ОтобратьПрикатСорт(МассивДокументовПрикат);
		Иначе		// Все остальные кроме  PRICAT'ов
			МассивДокументовПоТекущемуИнтерфейсу	= 
							ОтобратьДокументыПоИнтерфейсу(МассивДокументовДЗ, ТекущийИнтерфейсДокументаПоПриоритету);
		КонецЕсли;
				
		Для каждого ДокументМассива Из МассивДокументовПоТекущемуИнтерфейсу Цикл
			МассивДокументовПоРанжиру.Добавить(ДокументМассива);
		КонецЦикла;
	 
	КонецЦикла;
	
	Возврат МассивДокументовПоРанжиру;

КонецФункции// } #wortmann

// #wortmann { 
// Получает значение перечисления по его Наименованию 
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
//  ИмяЗначения - Строка - наименование интерфейса
//
// Возвращаемое значение:
// Результат - <ПеречислениеСсылка.гф_Интерфейсы> - если не найдено значение по Наименованию, то ПустаяСсылка()
//										иначе соответствующее значение.
//
Функция ПолучитьЗначениеПеречисленияИнтерфейсыПоИмени(ИмяЗначения)
	
	Результат =  Перечисления.гф_Интерфейсы.ПустаяСсылка();
	Для каждого ПеречислениеЗначение Из  Перечисления.гф_Интерфейсы Цикл
		Если СокрЛП(ПеречислениеЗначение) = ИмяЗначения Тогда
			Результат	= ПеречислениеЗначение;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Возврат	Результат;
	
КонецФункции// } #wortmann 

// #wortmann { 
// Функция сортирует документы в массиве по "по ранжиру" интерфейсов 
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
// 	МассивДокументовДЗ - Массив - массив из созданных документов ДокументОбъект.гф_ДанныеЗагрузки.
// 	ТекИнтерфейс - ПеречислениеСсылка.гф_Интерфейсы - Значение интерфеса. 
//
// Возвращаемое значение:
// МассивДокументовПоИнтерфейсу - Массив - массив из документов ДокументОбъект.гф_ДанныеЗагрузки с ТекИнтерфейсом.
Функция ОтобратьДокументыПоИнтерфейсу(МассивДокументовДЗ, ТекИнтерфейс)

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	гф_ДанныеЗагрузки.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.гф_ДанныеЗагрузки КАК гф_ДанныеЗагрузки
		|ГДЕ
		|	гф_ДанныеЗагрузки.Ссылка В(&МассивДокументов)
		|	И гф_ДанныеЗагрузки.Интерфейс = &Интерфейс
		|
		|УПОРЯДОЧИТЬ ПО
		|	гф_ДанныеЗагрузки.ДатаФайла";
	
	Запрос.УстановитьПараметр("Интерфейс", ТекИнтерфейс);
	Запрос.УстановитьПараметр("МассивДокументов", МассивДокументовДЗ);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	МассивДокументовПоИнтерфейсу	= Новый Массив;
	
	Пока Выборка.Следующий() Цикл
    МассивДокументовПоИнтерфейсу.Добавить(Выборка.Ссылка);
	КонецЦикла;
	
	//Для каждого ТекДокумент Из МассивДокументовДЗ Цикл
	//	Если ТекДокумент.Интерфейс = ТекИнтерфейс Тогда
	//		МассивДокументовПоИнтерфейсу.Добавить(ТекДокумент);	
	//	КонецЕсли;
	//КонецЦикла;		
	Возврат МассивДокументовПоИнтерфейсу;

КонецФункции// } #wortmann

// #wortmann { 
// Функция отбирает документы с интерфейсом PRICAT_SORT и переустанавливает в документе 
// гф_ДанныеЗагрузки значение интерфейса
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
//	МассивДокументовПрикат - Массив - массив из созданных документов ДокументОбъект.гф_ДанныеЗагрузки. 
//
// Возвращаемое значение:
//	МассивДокументов - Массив - массив из документов ДокументОбъект.гф_ДанныеЗагрузки с интерфейсом PRICAT_SORT.
// BSLLS:Typo-off
Функция ОтобратьПрикатСорт(МассивДокументовПрикат)
// BSLLS:Typo-on	
	МассивДокументов	= Новый Массив;
	// Выберем загружаемые поля для интерфейса PRICAT_SORT 
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	НастройкаЗагружаемыхДанных.СтатусПоля,
	|	НастройкаЗагружаемыхДанных.Ссылка,
	|	НастройкаЗагружаемыхДанных.Наименование
	|ИЗ
	|	Справочник.гф_НастройкаЗагружаемыхДанных КАК НастройкаЗагружаемыхДанных
	|ГДЕ
	|	НастройкаЗагружаемыхДанных.Интерфейс = &Интерфейс";
	Запрос.УстановитьПараметр("Интерфейс", Перечисления.гф_Интерфейсы.PRICAT_SORT);
	ЗагружаемыеПоля = Запрос.Выполнить().Выгрузить();
	
	// Запросом отбираем только Pricat_Sort
	// BSLLS:Typo-off
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Тэг_Group_type", "Group_type");
	Запрос.УстановитьПараметр("МассивДокументов", МассивДокументовПрикат);
	Запрос.УстановитьПараметр("Pricat_Sort", "10E");
	Запрос.Текст = "ВЫБРАТЬ
	               |	СтрокиДокументаДанныеЗагрузки.Документ КАК Ссылка
	               |ИЗ
	               |	РегистрСведений.гф_СтрокиДокументаДанныеЗагрузки КАК СтрокиДокументаДанныеЗагрузки
	               |ГДЕ
	               |	СтрокиДокументаДанныеЗагрузки.Документ В(&МассивДокументов)
	               |	И СтрокиДокументаДанныеЗагрузки.Тэг = &Тэг_Group_type
	               |	И СтрокиДокументаДанныеЗагрузки.Значение ПОДОБНО &Pricat_Sort
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	СтрокиДокументаДанныеЗагрузки.Документ.ДатаФайла";
	
	Результат			= Запрос.Выполнить();
	ВыборкаПрикатСорт 	= Результат.Выбрать();
	Пока ВыборкаПрикатСорт.Следующий() Цикл
		ДокументПрикатСорт = ВыборкаПрикатСорт.Ссылка.ПолучитьОбъект();
		ДокументПрикатСорт.Интерфейс = Перечисления.гф_Интерфейсы.PRICAT_SORT;
		ДокументПрикатСорт.Записать();
		МассивДокументов.Добавить(ДокументПрикатСорт.Ссылка);
		// Так как в Документы PRICAT_SORT установлены значения для PRICAT, меняем их на нужные
		НаборЗаписей = РегистрыСведений.гф_СтрокиДокументаДанныеЗагрузки.СоздатьНаборЗаписей();
		
		НаборЗаписей.Отбор.Документ.Установить(ДокументПрикатСорт.Ссылка);
		// BSLLS:Typo-on
		НаборЗаписей.Прочитать();
		Для Индекс = 0 По НаборЗаписей.Количество() - 1 Цикл
			Запись = НаборЗаписей[Индекс];
			Запись.ПолеЗагрузки = "";
			Если ЗначениеЗаполнено(ЗагружаемыеПоля) Тогда
				// BSLLS:Typo-off
				НайденноеЗначение = ЗагружаемыеПоля.Найти(Запись.Тэг, "Наименование");
				// BSLLS:Typo-on
				Если НайденноеЗначение <> Неопределено Тогда
					Запись.ПолеЗагрузки = НайденноеЗначение.Ссылка;
					Запись.СтатусПоля = НайденноеЗначение.СтатусПоля;
				КонецЕсли;
			КонецЕсли;
			
		КонецЦикла;
		НаборЗаписей.Записать();
	КонецЦикла;
	
	Возврат МассивДокументов;
	
КонецФункции// } #wortmann

// #wortmann { 
// Функция отбирает документы с интерфейсом PRICAT 
// Галфинд_Домнышева 2022/09/19
//
// Параметры:
//	МассивДокументовПрикат - Массив - массив из созданных документов ДокументОбъект.гф_ДанныеЗагрузки. 
//
// Возвращаемое значение:
// МассивДокументов - Массив - массив из документов ДокументОбъект.гф_ДанныеЗагрузки с интерфейсом PRICAT.
// BSLLS:Typo-off
Функция ОтобратьПрикат(МассивДокументовПрикат)
// BSLLS:Typo-on	
	МассивДокументов	= Новый Массив;
	
	// Запросом отбираем только Pricat
	// BSLLS:Typo-off
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Тэг_Group_type", "Group_type");
	Запрос.УстановитьПараметр("МассивДокументов", МассивДокументовПрикат);
	Запрос.УстановитьПараметр("Pricat", "3");
	Запрос.Текст = "ВЫБРАТЬ
	               |	СтрокиДокументаДанныеЗагрузки.Документ КАК Ссылка
	               |ИЗ
	               |	РегистрСведений.гф_СтрокиДокументаДанныеЗагрузки КАК СтрокиДокументаДанныеЗагрузки
	               |ГДЕ
	               |	СтрокиДокументаДанныеЗагрузки.Документ В(&МассивДокументов)
	               |	И СтрокиДокументаДанныеЗагрузки.Тэг = &Тэг_Group_type
	               |	И СтрокиДокументаДанныеЗагрузки.Значение ПОДОБНО &Pricat
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	СтрокиДокументаДанныеЗагрузки.Документ.ДатаФайла";
	// BSLLS:Typo-on
	Результат			= Запрос.Выполнить();
	Выборка 	= Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		МассивДокументов.Добавить(Выборка.Ссылка);
	КонецЦикла;
	
	Возврат МассивДокументов;
  
КонецФункции// } #wortmann

// #wortmann { 
// Процедура записывает строки в РС гф_ОшибкиЗагрузки по значениям из ТЗ "ТекстыОшибок" 
// Галфинд_Домнышева 2022/10/13
//
// Параметры:
//	ДокументДанные - ДокументСсылка.гф_ДанныеЗагрузки.
//
Процедура ЗаписатьОшибку(ДокументДанные)
	
	ТекущаяДата = ТекущаяДатаСеанса(); // Галфинд_Домнышева_20_03_2023
	Если ДокументДанные.ДополнительныеСвойства.Свойство("ТекстыОшибок") Тогда
		ТекстыОшибок = ДокументДанные.ДополнительныеСвойства.ТекстыОшибок;
		
		Попытка	
			НаборЗаписей = РегистрыСведений.гф_ОшибкиЗагрузки.СоздатьНаборЗаписей(); 
			//НаборЗаписей.Отбор.Дата.Установить(ДокументДанные.Дата); // Галфинд_Домнышева_20_03_2023 
			НаборЗаписей.Отбор.ПутьФайла.Установить(ДокументДанные.ПолноеИмяФайла);
			НаборЗаписей.Отбор.Организация.Установить(ДокументДанные.Организация);
			НаборЗаписей.Отбор.Интерфейс.Установить(ДокументДанные.Интерфейс);
			
			Для каждого Элемент Из ТекстыОшибок Цикл
				
				НоваяЗапись = НаборЗаписей.Добавить(); 
				//НоваяЗапись.Дата = Элемент.Дата; // Галфинд_Домнышева_20_03_2023
				НоваяЗапись.Дата = ТекущаяДата; 
				НоваяЗапись.ПутьФайла = Элемент.ПутьФайла; 
				НоваяЗапись.Номер = Элемент.Номер;
				НоваяЗапись.ТекстОшибки = Элемент.ТекстОшибки;
				НоваяЗапись.Организация = Элемент.Организация;
				НоваяЗапись.Интерфейс = Элемент.Интерфейс;
				НоваяЗапись.ТипИнформации = Элемент.ТипИнформации;
				
			КонецЦикла;
			НаборЗаписей.Записать();  
			
		Исключение
			СообщениеОбОшибке = "Ошибка при проведении документа " + ДокументДанные.Ссылка  
			+ ". Описание ошибки: Не удалось загрузить ТекстОшибки в РС гф_ОшибкиЗагрузки. " + ОписаниеОшибки();
			ЗаписьЖурналаРегистрации("Ошибка", УровеньЖурналаРегистрации.Ошибка, ДокументДанные.Ссылка, 
			ДокументДанные.Ссылка, СообщениеОбОшибке);		
		КонецПопытки;
	КонецЕсли;

КонецПроцедуры// } #wortmann

// #wortmann { 
// Функция получает ТЗ с данными по загружаемым полям  
// Галфинд_Домнышева 2022/10/17
//
// Параметры:
//	Интерфейс - ПеречислениеСсылка.гф_Интерфейсы - интерфейс создаваемого документа. 
//
// Возвращаемое значение:
//  ЗагружаемыеПоля - ТаблицаЗначений - ТЗ с полученными данными из справочника гф_НастройкаЗагружаемыхДанных.
Функция ПолучитьЗагружаемыеПоля(Интерфейс)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
		|	НастройкаЗагружаемыхДанных.СтатусПоля,
		|	НастройкаЗагружаемыхДанных.Ссылка,
		|	НастройкаЗагружаемыхДанных.Наименование
		|ИЗ
		|	Справочник.гф_НастройкаЗагружаемыхДанных КАК НастройкаЗагружаемыхДанных
		|ГДЕ
		|	НастройкаЗагружаемыхДанных.Интерфейс = &Интерфейс";
	
	Запрос.УстановитьПараметр("Интерфейс", Интерфейс);
	РезультатЗапроса = Запрос.Выполнить();
	ЗагружаемыеПоля = РезультатЗапроса.Выгрузить();
	Возврат ЗагружаемыеПоля; 
	
КонецФункции// } #wortmann

// #wortmann { 
// Создает каталог по дате загрузки и перемещает загруженные файлы из родительского каталога в созданный.  
// Галфинд_Домнышева 2022/12/29
//
// Параметры:
// ФайлыВАрхив - Массив - массив файлов для помещения в архив
// КаталогАрхива - Строка - Путь к Папке для архивации файлов
Процедура ЗаписатьВАрхивУдалитьИзКаталога(ФайлыВАрхив, КаталогАрхива) 
	
	ДатаАрхивации = ТекущаяДатаСеанса();
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
	
КонецФункции  

#КонецОбласти

#Область Инициализация
// Этой переменной регулируем количество "холостых" итераций цикла -
// тем самым устанавливаем интервал задержки до повторной попытки соединения
// после разрыва почтового соединения с почтовым сервером извне.
ИнтервалЗадержкиПодключенияПослеНеудачи = 1000;   
#КонецОбласти

#КонецЕсли