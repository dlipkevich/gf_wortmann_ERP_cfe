﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область СлужебныеПроцедурыИФункции

// #wortmann { 
// Процедура служит для вызова загрузки из Регламентного задания  
// Галфинд_Домнышева 2023/02/16
Процедура ВыполнитьЗагрузкуИРазборФайлов() Экспорт 
	
	МассивПапокЗагрузки = ПолучитьМассивПапокОрганизаций();
	
	Для каждого Строка Из МассивПапокЗагрузки Цикл 
		
		Логи = Строка.Логи;
		Архив = Строка.Архив;
		МассивФайлов = НайтиФайлы(Строка.Каталог, "*.xml");		
		
		НовыйМассивФайлов = ПреобразоватьМассив(МассивФайлов);
				
		ДанныеДляЗагрузки = Новый Массив;
		
		Если НовыйМассивФайлов.Количество() > 0 Тогда
			
			Для каждого Элемент Из НовыйМассивФайлов Цикл 
				
				НовыйЭлемент = Новый Структура("Адрес, ИмяБезРасширения, ИмяФайла, ПолноеИмя");
				НовыйЭлемент.ИмяФайла = Элемент.Имя;
				НовыйЭлемент.ИмяБезРасширения = Элемент.ИмяБезРасширения;
				НовыйЭлемент.ПолноеИмя = Элемент.ПолноеИмя;
				ДанныеДляЗагрузки.Добавить(НовыйЭлемент); 
				
			КонецЦикла;
			
			ФайлыВАрхив = ВыполнитьОбменДанными(ДанныеДляЗагрузки, Архив, Логи);
			
			Если ФайлыВАрхив.Количество() > 0 Тогда
				ЗаписатьВАрхивУдалитьИзКаталога(ФайлыВАрхив, Архив);
			КонецЕсли;	
		Иначе
			Сообщение = "В каталоге " + Строка.Каталог + " нет файлов с расширением .XML" ;
			ЗаписьЖурналаРегистрации("Информация", УровеньЖурналаРегистрации.Информация, ЭтотОбъект, ЭтотОбъект, Сообщение);
		КонецЕсли; 		
		
	КонецЦикла;
	
КонецПроцедуры// } #wortmann 

// #wortmann { 
// Преобразует массив, оставляя в нем только файлы "shippinglist" и "InvoiceAusgehend"
// Галфинд_Домнышева 2023/02/16
//
// Параметры:
//  МассивФайлов - Массив - Массив полученных файлов.
//
// Возвращаемое значение:
//	НовыйМассивФайлов - Массив
Функция ПреобразоватьМассив(МассивФайлов)
	
	НовыйМассивФайлов = Новый Массив;
	Для каждого Эл Из МассивФайлов Цикл
		Если СтрНайти(Эл.Имя, "shippinglist") > 0
			ИЛИ СтрНайти(Эл.Имя, "InvoiceAusgehend_V") > 0 Тогда
			НовыйМассивФайлов.Добавить(Эл);
		КонецЕсли;
	КонецЦикла;
	Возврат НовыйМассивФайлов;
	
КонецФункции// } #wortmann

// #wortmann { 
// Выгружает данные из справочника гф_КаталогиОбработкиФайловXML
// Галфинд_Домнышева 2023/02/16
//
// Возвращаемое значение:
//	МассивПапокЗагрузки - Массив структур с ключами "Каталог, Архив, Логи"
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
		 Элемент = Новый Структура("Каталог, Архив, Логи");
		 ЗаполнитьЗначенияСвойств(Элемент, Выборка);
		 МассивПапокЗагрузки.Добавить(Элемент);
	КонецЦикла;
	
	Возврат МассивПапокЗагрузки;
	
КонецФункции// } #wortmann  

// #wortmann { 
// Экспортная функция по загрузке полученных файлов 
// Галфинд_Домнышева 2023/02/16
//
// Параметры:
//  ФайлыЗагрузки - Массив - Массив полученных файлов. 
//	КаталогАрхива - строка - путь к каталогу для архивации
//	КаталогЛоги - строка -  путь к каталогу для хранения логов
//
// Возвращаемое значение:
// ФайлыВАрхив - Массив - Массив успешно загруженных файлов для их дальнейшей архивации.
//
Функция ВыполнитьОбменДанными(ФайлыЗагрузки, КаталогАрхива, КаталогЛоги) Экспорт
	
	КаталогНаДиске = Новый Файл(КаталогАрхива);
	Если НЕ КаталогНаДиске.Существует() Тогда
		СоздатьКаталог(КаталогАрхива);
	КонецЕсли;
	
	КаталогНаДиске = Новый Файл(КаталогЛоги);
	Если НЕ КаталогНаДиске.Существует() Тогда
		СоздатьКаталог(КаталогЛоги);
	КонецЕсли;
	
	МассивШипЛистов = Новый Массив;
	МассивИнвойсов = Новый Массив;
	
	Для каждого мФайл Из ФайлыЗагрузки Цикл
		Структура = Новый Структура;
		ЧтениеXML = Новый ЧтениеXML;
		
		Если ЗначениеЗаполнено(мФайл.Адрес) Тогда
			ДвоичныеДанные = ПолучитьИзВременногоХранилища(мФайл.Адрес);
			ИмяВременногоФайла = ПолучитьИмяВременногоФайла("xml"); 
			ДвоичныеДанные.Записать(ИмяВременногоФайла);
			ЧтениеXML.ОткрытьФайл(ИмяВременногоФайла);
			АдресФайла = мФайл.Адрес;
		Иначе
			ЧтениеXML.ОткрытьФайл(мФайл.ПолноеИмя);
			ДвоичныеДанные = Новый ДвоичныеДанные(мФайл.ПолноеИмя);
			АдресФайла = ПоместитьВоВременноеХранилище(ДвоичныеДанные);
		КонецЕсли;
		
		ДокументХДТО = ФабрикаXDTO.ПрочитатьXML(ЧтениеXML); 
		
		Если СтрНайти(мФайл.ИмяБезРасширения, "shippinglist") > 0 Тогда 
			
			//ДвоичныеДанные = Новый ДвоичныеДанные(мФайл.ПолноеИмя);
			//АдресФайла = ПоместитьВоВременноеХранилище(ДвоичныеДанные);
			Если  ТипЗнч(ДокументХДТО.shipping_unit) = Тип("СписокXDTO") Тогда
				//Для каждого СтрокаФайла Из ДокументХДТО.shipping_unit Цикл 
				ШипЛист = Новый Структура;
				ШипЛист.Вставить("ПолныПутьШипЛиста", мФайл.ПолноеИмя); 
				ШипЛист.Вставить("ИмяФайлаШипЛист", мФайл.ИмяБезРасширения);
				ШипЛист.Вставить("shipping_unit_no", ДокументХДТО.shipping_unit[0].shipping_unit_no);
				//ШипЛист.Вставить("customs_invoice_no", СтрокаФайла.customs_invoice_no);
				ШипЛист.Вставить("ИнвойсЕсть", Ложь);
				ШипЛист.Вставить("АдресШипЛиста", АдресФайла);
				
				МассивШипЛистов.Добавить(ШипЛист);
				//КонецЦикла;
			Иначе
				ШипЛист = Новый Структура;
				ШипЛист.Вставить("ПолныПутьШипЛиста", мФайл.ПолноеИмя); 
				ШипЛист.Вставить("ИмяФайлаШипЛист", мФайл.ИмяБезРасширения);
				ШипЛист.Вставить("shipping_unit_no", ДокументХДТО.shipping_unit.shipping_unit_no);
				//ШипЛист.Вставить("customs_invoice_no", ДокументХДТО.shipping_unit.customs_invoice_no);
				ШипЛист.Вставить("ИнвойсЕсть", Ложь);
				ШипЛист.Вставить("АдресШипЛиста", АдресФайла);
				
				МассивШипЛистов.Добавить(ШипЛист); 
			КонецЕсли;
		ИначеЕсли СтрНайти(мФайл.ИмяБезРасширения, "InvoiceAusgehend") > 0 Тогда
			
			//ДвоичныеДанные = Новый ДвоичныеДанные(мФайл.ПолноеИмя); 
			//АдресФайла = ПоместитьВоВременноеХранилище(ДвоичныеДанные);
			
			Инвойс = Новый Структура;                 
			Инвойс.Вставить("ПолныйПутьИнвойс", мФайл.ПолноеИмя); 
			Инвойс.Вставить("ИмяФайлаИнвойс", мФайл.ИмяБезРасширения);
			Инвойс.Вставить("Номер", ДокументХДТО.Message_Header.Document_number);
			Инвойс.Вставить("Дата", Дата(ДокументХДТО.Message_Header.Document_date));
			Инвойс.Вставить("Валюта", ДокументХДТО.Message_Header.Currency);
			Инвойс.Вставить("GLN_supplier", ДокументХДТО.Message_Header.GLN_supplier);
			Инвойс.Вставить("GLN_customer", ДокументХДТО.Message_Header.GLN_customer);
			Инвойс.Вставить("shipment_number", ДокументХДТО.Message_Header.Shipment_number);			 
			Инвойс.Вставить("Обработан", Ложь);
			Инвойс.Вставить("ПолныПутьШипЛиста", "");
			Инвойс.Вставить("ИмяФайлаШипЛист", "");			
			Инвойс.Вставить("АдресИнвойса", АдресФайла); 
			Инвойс.Вставить("АдресШипЛиста", Неопределено);
			
			МассивИнвойсов.Добавить(Инвойс); 
		Иначе
			Продолжить;
		КонецЕсли;	
		
	КонецЦикла;
		
	ФайлыВАрхив = СопоставитьИнвойсИШипЛист(МассивИнвойсов, МассивШипЛистов, КаталогАрхива, КаталогЛоги);
	
	Возврат ФайлыВАрхив;
КонецФункции// } #wortmann

Функция СопоставитьИнвойсИШипЛист(МассивИнвойсов, МассивШипЛистов, КаталогАрхива, КаталогЛоги)
	
	ТаблицаШипЛистов = ПеревестиСтруктуруВТаблицу(МассивШипЛистов);
	
	ДатаАрхивации = ТекущаяДатаСеанса();
	ДатаАрхивации = Формат(ДатаАрхивации, "ДФ = ггггММдд");
	КаталогЛог = КаталогЛоги + "\" + ДатаАрхивации;               
	
	КаталогНаДиске = Новый Файл(КаталогЛог);
	Если НЕ КаталогНаДиске.Существует() Тогда
		СоздатьКаталог(КаталогЛог);
	КонецЕсли;
	
	МассивОбработанныхФайлов = Новый Массив;
	МассивИмен = Новый Массив;
	
	Для каждого Инвойс Из МассивИнвойсов Цикл
		
		НайденнаяСтрока = ТаблицаШипЛистов.Найти(Инвойс.shipment_number, "shipping_unit_no");
		Если НайденнаяСтрока <> Неопределено Тогда
			Инвойс.ИмяФайлаШипЛист = НайденнаяСтрока.ИмяФайлаШипЛист;
			Инвойс.ПолныПутьШипЛиста = НайденнаяСтрока.ПолныПутьШипЛиста;
			Инвойс.АдресШипЛиста = НайденнаяСтрока.АдресШипЛиста;
			
			ЗагрузитьДанныеНаСервере(Инвойс, КаталогАрхива, КаталогЛог, МассивОбработанныхФайлов, МассивИмен);
		КонецЕсли;	
		
	КонецЦикла; 
	
	Возврат МассивОбработанныхФайлов;
	
КонецФункции

Процедура ЗагрузитьДанныеНаСервере(Инвойс, КаталогАрхива, КаталогЛог, МассивОбработанныхФайлов, МассивИмен) 
			
	Макет = ПолучитьМакет("ЛогЗагрузки1");	
	КаталогВременныхФайлов = КаталогВременныхФайлов(); 
	
	ИмяВременногоФайлаИнвойс = КаталогВременныхФайлов + Инвойс.ИмяФайлаИнвойс + ".xml";
	ИмяВременногоФайлаШипЛиста = КаталогВременныхФайлов + Инвойс.ИмяФайлаШипЛист + ".xml";
	
	мФайл = Новый Файл(ИмяВременногоФайлаИнвойс);
	Если мФайл.Существует() Тогда
		УдалитьФайлы(ИмяВременногоФайлаИнвойс);
	КонецЕсли;
	
	мФайл = Новый Файл(ИмяВременногоФайлаШипЛиста);
	Если мФайл.Существует() Тогда
		УдалитьФайлы(ИмяВременногоФайлаШипЛиста);
	КонецЕсли;
	
	ДвоичныеДанныеИнвойс = ПолучитьИзВременногоХранилища(Инвойс.АдресИнвойса);
	ДвоичныеДанныеИнвойс.Записать(ИмяВременногоФайлаИнвойс);
	ЧтениеИнвойс = Новый ЧтениеXML;
	ЧтениеИнвойс.ОткрытьФайл(ИмяВременногоФайлаИнвойс);
	
	ДвоичныеДанныеШипЛиста = ПолучитьИзВременногоХранилища(Инвойс.АдресШипЛиста);
	ДвоичныеДанныеШипЛиста.Записать(ИмяВременногоФайлаШипЛиста); 
	ЧтениеШипЛиста = Новый ЧтениеXML;
	ЧтениеШипЛиста.ОткрытьФайл(ИмяВременногоФайлаШипЛиста);
	
	ДокументХДТОИнвойс = ФабрикаXDTO.ПрочитатьXML(ЧтениеИнвойс);
	ДокументХДТОШипЛист = ФабрикаXDTO.ПрочитатьXML(ЧтениеШипЛиста);
	
	ТаблицаИнвойса = СписокXDTOВТаблицу(ДокументХДТОИнвойс.Message_Header.Message_Position);
	//ТаблицаШипЛиста =  СписокXDTOВТаблицу(ДокументХДТОШипЛист.shipping_unit.customer); // Галфинд_ДомнышеваКР_20_03_2023
	ТаблицаШипЛиста = ПривестиТаблицуШипЛистаВЧитаемыйВид(ДокументХДТОШипЛист, Инвойс.Номер); // Галфинд_ДомнышеваКР_20_03_2023
	//ПривестиТаблицуШипЛистаВЧитаемыйВид(ТаблицаШипЛиста); // Галфинд_ДомнышеваКР_20_03_2023	
	ТаблицаШипЛиста.Сортировать("order_no");
	ТаблицаИнвойса.Сортировать("Supplier_order_number");
	НомерДокумента = Инвойс.Номер;
	ДатаДокумента = Инвойс.Дата;
	
	НайденныйДокумент = ПолучитьДокументПТУ(НомерДокумента, ДатаДокумента);
	
	Если НайденныйДокумент = Документы.ПриобретениеТоваровУслуг.ПустаяСсылка() Тогда 
			ТабличныйДокумент = Новый ТабличныйДокумент;
           СозданиеДокументаПТУ(ТабличныйДокумент, Инвойс, ТаблицаИнвойса, ТаблицаШипЛиста, Макет);			
	Иначе
		
		НоваяСтрокаТЗ = СозданныеДокументы.Добавить();
		НоваяСтрокаТЗ.Документ = НайденныйДокумент;
		НоваяСтрокаТЗ.Новый = Ложь;
		НоваяСтрокаТЗ.Проведен = НайденныйДокумент.Проведен;

		ТабличныйДокумент = Новый ТабличныйДокумент;  
		ОбластьШапка = Макет.ПолучитьОбласть("Шапка"); 
		ОбластьШапка.Параметры.СтатусЗагрузки = "Документ был загружен ранее.";
		ОбластьШапка.Параметры.НомерДокумента = НайденныйДокумент.Номер;
		ОбластьШапка.Параметры.НомерДокумента = НайденныйДокумент.Дата;
		ОбластьШапка.Параметры.Контрагент = НайденныйДокумент.Контрагент;
		ОбластьШапка.Параметры.Партнер =  НайденныйДокумент.Контрагент.Партнер;
		ОбластьШапка.Параметры.Валюта  = НайденныйДокумент.Валюта;
		ОбластьШапка.Параметры.Договор = НайденныйДокумент.Договор;
		
		ТабличныйДокумент.Вывести(ОбластьШапка); 
		
	КонецЕсли;	
	
	Инвойс.Обработан = Истина;
	
	ИмяФайлаЛога = КаталогВременныхФайлов + "ДанныеЗагрузки_" + НомерДокумента + ".xlsx";
	ТабличныйДокумент.Записать(ИмяФайлаЛога, ТипФайлаТабличногоДокумента.XLSX);
	КопироватьФайл(ИмяФайлаЛога, КаталогЛог + "\" + "ДанныеЗагрузки_" + НомерДокумента + ".xlsx");

	СтруктураИнвойс = Новый Структура("Имя, ПолноеИмя");	
	СтруктураИнвойс.Имя = Инвойс.ИмяФайлаИнвойс;
	СтруктураИнвойс.ПолноеИмя = Инвойс.ПолныйПутьИнвойс;
	
	Если МассивИмен.Найти(Инвойс.ПолныйПутьИнвойс) = Неопределено Тогда
		МассивИмен.Добавить(Инвойс.ПолныйПутьИнвойс);
		МассивОбработанныхФайлов.Добавить(СтруктураИнвойс);
	КонецЕсли;
	
	СтруктураШипЛист = Новый Структура("Имя, ПолноеИмя");
	СтруктураШипЛист.Имя = Инвойс.ИмяФайлаШипЛист;
	СтруктураШипЛист.ПолноеИмя = Инвойс.ПолныПутьШипЛиста;
	
	Если МассивИмен.Найти(Инвойс.ПолныПутьШипЛиста) = Неопределено Тогда
		МассивИмен.Добавить(Инвойс.ПолныПутьШипЛиста);
		МассивОбработанныхФайлов.Добавить(СтруктураШипЛист);
	КонецЕсли;
	
КонецПроцедуры 

Процедура СозданиеДокументаПТУ(ТабличныйДокумент, Инвойс, ТаблицаИнвойса, ТаблицаШипЛиста, Макет)
	
	ТекстЛога = "";

	НомерДокумента = Инвойс.Номер;                                       
	ДатаДокумента = Инвойс.Дата;                                                     

	Поставщик = Справочники.Контрагенты.НайтиПоРеквизиту("гф_GLN_номер", Инвойс.GLN_supplier);
	Организация = Справочники.Организации.НайтиПоРеквизиту("гф_RC_GLN_номер", Инвойс.GLN_customer);
	Валюта = Справочники.Валюты.НайтиПоНаименованию(Инвойс.Валюта);
	ХозОперация = Перечисления.ХозяйственныеОперации.ЗакупкаПоИмпорту;                                     
	
	ТаможенныйСклад = НайтиДополнительныйРеквизитПоИдентификатору("гф_ОрганизацииТаможенныйСклад");
	Склад = УправлениеСвойствами.ЗначениеСвойства(Организация, ТаможенныйСклад);
	
	ПараметрыПоискаДоговора = Новый Структура;
	ПараметрыПоискаДоговора.Вставить("ВалютаДоговора", Валюта);
	ПараметрыПоискаДоговора.Вставить("ДатаДокумента", ДатаДокумента);
	ПараметрыПоискаДоговора.Вставить("Контрагент", Поставщик);
	
	Договор = ПолучитьДоговор(ПараметрыПоискаДоговора, ТекстЛога);
	
	ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
	ОбластьШапка.Параметры.НомерДокумента = НомерДокумента;
	ОбластьШапка.Параметры.НомерДокумента = ДатаДокумента;
	ОбластьШапка.Параметры.Контрагент = ?(ЗначениеЗаполнено(Поставщик), Поставщик, 
										"Не найден контрагент с кодом " + Инвойс.GLN_customer);
	ОбластьШапка.Параметры.Партнер =  Поставщик.Партнер;
	ОбластьШапка.Параметры.Валюта  = ?(ЗначениеЗаполнено(Валюта), Валюта, 
										"Не найдена валюта с символьным кодом " + Инвойс.Валюта);
	ОбластьШапка.Параметры.Договор = ?(ЗначениеЗаполнено(Договор), Договор, "Не найден или найдено несколько записей ");
	
	ТабличныйДокумент.Вывести(ОбластьШапка);
	
	ДокументОбъект  = Документы.ПриобретениеТоваровУслуг.СоздатьДокумент();
	СсылкаДокумента = ДокументОбъект.ПолучитьСсылкуНового();
	ДокументОбъект.Номер = НомерДокумента;
	ДокументОбъект.Дата = ДатаДокумента;
	ДокументОбъект.Организация = Организация;
	ДокументОбъект.Контрагент = Поставщик;
	ДокументОбъект.Партнер = ДокументОбъект.Контрагент.Партнер;
	ДокументОбъект.ХозяйственнаяОперация = ХозОперация;
	ДокументОбъект.Валюта = Валюта;
	ДокументОбъект.Договор =  Договор;
	
	ДокументОбъект.ВалютаВзаиморасчетов = Договор.ВалютаВзаиморасчетов;
	ДокументОбъект.Склад = Склад;                          
	ДокументОбъект.ВариантПриемкиТоваров = Договор.ВариантПриемкиТоваров;
	ДокументОбъект.ЗакупкаПодДеятельность = Перечисления.ТипыНалогообложенияНДС.ПродажаОблагаетсяНДС;
	ДокументОбъект.СпособДоставки = Перечисления.СпособыДоставки.СиламиПоставщикаДоНашегоСклада;
	
	ДокументОбъект.ОбменДанными.Загрузка = Истина;
	ДокументОбъект.Записать();
	
	// ++ Галфинд_Домнышева_17_03_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=812ebcee7bda45d711edc48ef1236fff
	СвойствоПроверкаПТУ = НайтиДополнительныйРеквизитПоИдентификатору("гф_ПТУПроверкаПТУ");
		
	Если ЗначениеЗаполнено(СвойствоПроверкаПТУ) Тогда
		// определим значение Ошибка
		ЗначенияСвойстваПТУ = УправлениеСвойствамиСлужебный.ДополнительныеЗначенияСвойства(СвойствоПроверкаПТУ);
		Для Каждого ЗначениеСвойстваПТУ Из ЗначенияСвойстваПТУ Цикл 
			Если ЗначениеСвойстваПТУ.Наименование = "Загружен" Тогда 
				ЗначениеПроверкаПТУ = ЗначениеСвойстваПТУ;
				Прервать;
			КонецЕсли;
		КонецЦикла; 
		ТаблицаСвойствИЗначений = Новый ТаблицаЗначений;
		ТаблицаСвойствИЗначений.Колонки.Добавить("Свойство", Новый ОписаниеТипов("ПланВидовХарактеристикСсылка.ДополнительныеРеквизитыИСведения"));
		ТаблицаСвойствИЗначений.Колонки.Добавить("Значение");
		СтрокаДопРеквизитов = ТаблицаСвойствИЗначений.Добавить();
		СтрокаДопРеквизитов.Свойство = СвойствоПроверкаПТУ;
		СтрокаДопРеквизитов.Значение = ЗначениеПроверкаПТУ;	
		
		УправлениеСвойствами.ЗаписатьСвойстваУОбъекта(ДокументОбъект.Ссылка, ТаблицаСвойствИЗначений);
	КонецЕсли;
    // -- Галфинд_Домнышева_17_03_2023 
	
	ВременнаяТаблицаВКоробах = ДокументОбъект.гф_ПродукцияВКоробах.Выгрузить();
	
	Для каждого СтрокаИнвойса Из ТаблицаИнвойса Цикл
		
		order_no = СтрокаИнвойса.Supplier_order_number;
		article_ean = СтрокаИнвойса.EAN;
		
		Артикул =  СтрокаИнвойса.Supplier_article_number;
		
		Номенклатура = Справочники.Номенклатура.НайтиПоРеквизиту("Артикул", Артикул);
		
		СтоимостьКороба = Число(СтрокаИнвойса.Position_amount);
		
		СтоимостьУЛ = Число(СтрокаИнвойса.Effective_purchase_price);
		
		Отбор = Новый Структура;
		Отбор.Вставить("order_no", order_no);
		Отбор.Вставить("article_ean", article_ean);			
		
		НайденныеСтроки = ТаблицаШипЛиста.НайтиСтроки(Отбор);
		
		ПараметрыЗаполненияУЛ = Новый Структура;
		ПараметрыЗаполненияУЛ.Вставить("Организация", Организация);
		ПараметрыЗаполненияУЛ.Вставить("НомерДокумента", НомерДокумента);
		ПараметрыЗаполненияУЛ.Вставить("ДатаДокумента", ДатаДокумента);
		ПараметрыЗаполненияУЛ.Вставить("ИмяФайлаШипЛист", Инвойс.ИмяФайлаШипЛист);
		ПараметрыЗаполненияУЛ.Вставить("СтоимостьУЛ", СтоимостьУЛ);

		ЗаполнитьДокументУпаковочныйЛист(НайденныеСтроки, Макет, ВременнаяТаблицаВКоробах, ТабличныйДокумент,
											ПараметрыЗаполненияУЛ, ДокументОбъект);	
		
	КонецЦикла;	
	
	ДокументОбъект.гф_ПродукцияВКоробах.Загрузить(ВременнаяТаблицаВКоробах);
	ДокументОбъект.гф_ПересчитатьТЧТоварыНаОсновнииКоробов(); 
	
	ДокументОбъект.ОбменДанными.Загрузка = Истина;
	ДокументОбъект.Записать();    
	ТекстОшибкиПроведения = "";		
	
	Попытка
		ДокументОбъект.ОбменДанными.Загрузка = Ложь;
		ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
	Исключение
		ТекстОшибкиПроведения = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;	
	
	НоваяСтрокаТЗ = СозданныеДокументы.Добавить();
	НоваяСтрокаТЗ.Документ = ДокументОбъект.Ссылка;
	НоваяСтрокаТЗ.Новый = Истина;
	НоваяСтрокаТЗ.Проведен = ДокументОбъект.Ссылка.Проведен;
	
	ОбластьОшибкиПроведения = Макет.ПолучитьОбласть("ОшибкаПроведения");
	ОбластьОшибкиПроведения.Параметры.ОшибкаПроведения = ТекстОшибкиПроведения;
	ТабличныйДокумент.Вывести(ОбластьОшибкиПроведения);
	
КонецПроцедуры

Процедура ЗаполнитьДокументУпаковочныйЛист(НайденныеСтроки, Макет, ВременнаяТаблицаВКоробах, ТабличныйДокумент,
											ПараметрыЗаполненияУЛ, ДокументОбъект)
	
	Для каждого СтрокаШипинг Из НайденныеСтроки Цикл
		
		ОбластьСтрока = Макет.ПолучитьОбласть("Строка"); 
		
		НовыйДокументУЛ = ПолучитьДокументУпаковочныйЛист(СтрокаШипинг.carton_no, ПараметрыЗаполненияУЛ.Организация);
	
		НовыйДокументУЛ.гф_Организация = ПараметрыЗаполненияУЛ.Организация;
		НовыйДокументУЛ.Код = СтрокаШипинг.carton_no;
		НовыйДокументУЛ.Дата = ПараметрыЗаполненияУЛ.ДатаДокумента;
		НовыйДокументУЛ.Вид = Перечисления.ВидыУпаковочныхЛистов.Входящий;
		НовыйДокументУЛ.гф_СостояниеКороба = Справочники.гф_СостянияКоробов.ПолныйКомплект;
		Вариант = СокрЛП(СтрокаШипинг.article_no);
		НовыйДокументУЛ.гф_Комплектация = НайтиЗначениеПоРеквизитуСправочника("ВариантыКомплектацииНоменклатуры",
			"Наименование", Вариант);
		
		КодЗаказа = СтрокаШипинг.order_no;
		ДатаЗаказа = Дата(СтрЗаменить(СтрокаШипинг.order_date, "-", ""));
		ИмяЗаказа = СтрокаШипинг.customer_order_no;
		
		Если ТипЗнч(ИмяЗаказа) = Тип("Строка") Тогда
			НовыйДокументУЛ.гф_Заказ = ПолучитьЗаказКлиента(КодЗаказа, ДатаЗаказа, ИмяЗаказа); 					
		Иначе
			НовыйДокументУЛ.гф_Заказ = Документы.ЗаказКлиента.ПустаяСсылка(); 
			ИмяЗаказа = "";
		КонецЕсли;	
		
		НовыйДокументУЛ.гф_Поставка = ДокументОбъект.Ссылка;
		НовыйДокументУЛ.гф_ФайлЗагрузки = ПараметрыЗаполненияУЛ.ИмяФайлаШипЛист + ".xml";
		
		НовыйДокументУЛ.Товары.Очистить();
		
		Для Каждого СтрокаСостава Из НовыйДокументУЛ.гф_Комплектация.Товары Цикл
			НоваяСтрока = НовыйДокументУЛ.Товары.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаСостава);
			НоваяСтрока.Назначение = Справочники.Назначения.гф_Техническое;
		КонецЦикла;															
		
		НовыйДокументУЛ.ВсегоМест = НовыйДокументУЛ.Товары.Итог("Количество");
		
		НовыйДокументУЛ.ОбменДанными.Загрузка = Истина;
		НовыйДокументУЛ.Записать(); 
		ДокументУпаковочныйЛист = НовыйДокументУЛ.Ссылка;				
		
		ОшибкиСозданияУЛ = "";				
		Если Не ЗначениеЗаполнено(ДокументУпаковочныйЛист.гф_Комплектация) Тогда
			ОшибкиСозданияУЛ = ОшибкиСозданияУЛ + Символы.ПС + "Не найдена комплектация " +
			СокрЛП(СтрокаШипинг.article_no) ;
		ИначеЕсли Не ЗначениеЗаполнено(ДокументУпаковочныйЛист.гф_Заказ) Тогда
			ОшибкиСозданияУЛ = ОшибкиСозданияУЛ + Символы.ПС + "Не найден заказ с параметрами " +
			Строка(КодЗаказа) + " " + Строка(ДатаЗаказа) + " " + Строка(ИмяЗаказа);	
		Иначе
			ОшибкиСозданияУЛ = ОшибкиСозданияУЛ + "";
		КонецЕсли;
		
		НоваяСтрокаКороба = ВременнаяТаблицаВКоробах.Добавить();
		НоваяСтрокаКороба.ВариантКомплектации = ДокументУпаковочныйЛист.гф_Комплектация;
		НоваяСтрокаКороба.КоличествоКоробов = 1;
		НоваяСтрокаКороба.IDКороба = ДокументУпаковочныйЛист;
		НоваяСтрокаКороба.СтоимостьКороба = ПараметрыЗаполненияУЛ.СтоимостьУЛ;
		
		ОбластьСтрока.Параметры.НомерСтроки = НоваяСтрокаКороба.НомерСтроки;
		ОбластьСтрока.Параметры.Номенклатура = ?(ЗначениеЗаполнено(НоваяСтрокаКороба.ВариантКомплектации),
		НоваяСтрокаКороба.ВариантКомплектации, "Не найдена комплектация");
		ОбластьСтрока.Параметры.Артикул     = НоваяСтрокаКороба.ВариантКомплектации.Владелец.Артикул;
		ОбластьСтрока.Параметры.УпаковочныйЛист = ?(ЗначениеЗаполнено(ОшибкиСозданияУЛ),
		"При создании УЛ " + Строка(ДокументУпаковочныйЛист) + " произошли ошибки " + ОшибкиСозданияУЛ,
		Строка(ДокументУпаковочныйЛист) + " загружен.");
		
		ТабличныйДокумент.Вывести(ОбластьСтрока);				
	КонецЦикла;	

КонецПроцедуры 

// #wortmann { 
// Находит значение в справочнике по указанному реквизиту 
// Галфинд_Домнышева 2022/10/14
//
// Параметры:
//	Справочник - Строка - имя справочника.
//	Реквизит - Строка - имя реквизита.
//	Значение - Строка - Значение искомого реквизита.
//
// Возвращаемое значение:
//	СправочникСсылка - если значение найдено, 
//	Неопределено - если значение реквизита в указанном справочнике не найдено.
//
Функция НайтиЗначениеПоРеквизитуСправочника(Справочник, Реквизит, Значение)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Спр.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник." + Справочник + " КАК Спр
		|ГДЕ
		|	Спр." + Реквизит + " = &Значение
		| И Спр.ПометкаУдаления = Ложь";
	
	Запрос.УстановитьПараметр("Значение", Значение);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Возврат Выборка.Ссылка;
	КонецЦикла;
	
    Возврат Неопределено;
КонецФункции// } #wortmann

// #wortmann { 
// Находит значение в ПВХ ДополнительныеРеквизитыИСведения по Идентификатору для формул 
// Галфинд_Домнышева 2022/10/19
//
// Параметры:
//	Наименование - Строка - имя искомого реквизита.
//
// Возвращаемое значение:
//	ПланВидовХарактеристикСсылка - если значение найдено, 
//	Неопределено - если значение реквизита не найдено.
//
Функция НайтиДополнительныйРеквизитПоИдентификатору(Наименование)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДополнительныеРеквизитыИСведения.Ссылка КАК Ссылка
		|ИЗ
		|	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК ДополнительныеРеквизитыИСведения
		|ГДЕ
		|	ДополнительныеРеквизитыИСведения.ИдентификаторДляФормул = &ИдентификаторДляФормул";
	
	Запрос.УстановитьПараметр("ИдентификаторДляФормул", Наименование);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка.Следующий();
		Возврат Выборка.Ссылка;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции// } #wortmann

// #wortmann { 
// Получает данные из XML ШипингЛиста по нужному инвойсу и формирует таблицу 
// Галфинд_Домнышева 2023/03/20
//
// Параметры:
//	ДокументХДТО - СписокXDTO - Прочитанный файл XML ШипингЛиста.
//	ИнвойсНомер - Строка - номер документа Инвойса
//
// Возвращаемое значение:
//	ТаблицаШипЛиста - ТаблицаЗначений 
//
Функция ПривестиТаблицуШипЛистаВЧитаемыйВид(ДокументХДТО, ИнвойсНомер)
	
	Если ТипЗнч(ДокументХДТО.shipping_unit) = Тип("СписокXDTO") Тогда
		Для каждого Строка Из ДокументХДТО.shipping_unit Цикл
			Если Прав(Строка.customs_invoice_no, 3) = Прав(ИнвойсНомер, 3) Тогда
				 ТаблицаШипЛиста = СписокXDTOВТаблицу(Строка.customer);
			 КонецЕсли;
		КонецЦикла;
	Иначе
		ТаблицаШипЛиста = СписокXDTOВТаблицу(ДокументХДТО.shipping_unit.customer)
		
	КонецЕсли;
	
	мТаблицаШипЛиста = ТаблицаШипЛиста.СкопироватьКолонки(); 
	
	мТаблицаШипЛиста.Колонки.Добавить("order_no"); 
	мТаблицаШипЛиста.Колонки.Добавить("customer_order_no");
	мТаблицаШипЛиста.Колонки.Добавить("order_date");
	
	мТаблицаШипЛиста.Колонки.Добавить("position_no");
	мТаблицаШипЛиста.Колонки.Добавить("article_no");
	мТаблицаШипЛиста.Колонки.Добавить("article_ean");
	мТаблицаШипЛиста.Колонки.Добавить("quantity"); 
	мТаблицаШипЛиста.Колонки.Добавить("carton_no");
	
	Для каждого Строка Из ТаблицаШипЛиста Цикл 		
		
		СписокОрдеров = ПолучитьСписок(Строка, "order");		
		
		Для каждого Ордер Из СписокОрдеров Цикл
			
			СписокПозиций = ПолучитьСписок(Ордер, "position"); 
			
			Для каждого Позиция Из СписокПозиций Цикл
				
				СписокНомеров = ПолучитьСписок(Позиция, "carton_no"); 
				
				Для каждого Номер Из СписокНомеров Цикл
					
					НоваяСтрока =  мТаблицаШипЛиста.Добавить();
					ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
					ЗаполнитьЗначенияСвойств(НоваяСтрока, Ордер);
					ЗаполнитьЗначенияСвойств(НоваяСтрока, Позиция);
					НоваяСтрока.carton_no = Номер;
					
				КонецЦикла;	
				
			КонецЦикла;	
			
		КонецЦикла;			
		
	КонецЦикла;
	
	ТаблицаШипЛиста = мТаблицаШипЛиста;
	Возврат ТаблицаШипЛиста;
	
КонецФункции// } #wortmann

Функция ПолучитьЗаказКлиента(НомерЗаказа, ДатаЗаказа, ИмяЗаказа)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ЗаказКлиента.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.ЗаказКлиента КАК ЗаказКлиента
	|ГДЕ
	|	ЗаказКлиента.ПометкаУдаления = ЛОЖЬ
	|	И ЗаказКлиента.гф_ИмяЗаказа = &ИмяЗаказа
	|	И ЗаказКлиента.Номер = &Номер
	|	И ЗаказКлиента.Дата = &Дата";
	
	Запрос.УстановитьПараметр("ИмяЗаказа", ИмяЗаказа);
	Запрос.УстановитьПараметр("Номер", НомерЗаказа);
	Запрос.УстановитьПараметр("Дата", ДатаЗаказа);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат Документы.ЗаказКлиента.ПустаяСсылка();
	Иначе
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Возврат Выборка.Ссылка;
	КонецЕсли;	
	
КонецФункции

Функция ПолучитьДокументУпаковочныйЛист(КодУЛ, Организация)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	УпаковочныйЛист.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.УпаковочныйЛист КАК УпаковочныйЛист
	|ГДЕ
	|	УпаковочныйЛист.ПометкаУдаления = ЛОЖЬ
	|	И УпаковочныйЛист.Код = &Код
	|	И УпаковочныйЛист.гф_Организация = &Организация";	
	
	Запрос.УстановитьПараметр("Код", КодУЛ);
	Запрос.УстановитьПараметр("Организация", Организация);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат Документы.УпаковочныйЛист.СоздатьДокумент();
	Иначе
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Возврат Выборка.Ссылка.ПолучитьОбъект();
	КонецЕсли;
	
КонецФункции	

Функция ПолучитьДокументПТУ(Номер, Дата)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПриобретениеТоваровУслуг.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.ПриобретениеТоваровУслуг КАК ПриобретениеТоваровУслуг
	|ГДЕ
	|	ПриобретениеТоваровУслуг.ПометкаУдаления = ЛОЖЬ
	|	И ПриобретениеТоваровУслуг.Номер = &Номер
	|	И ПриобретениеТоваровУслуг.Дата = &Дата";
	
	Запрос.УстановитьПараметр("Номер", Номер);
	Запрос.УстановитьПараметр("Дата", Дата);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат Документы.ПриобретениеТоваровУслуг.ПустаяСсылка();
	Иначе
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		Возврат Выборка.Ссылка;
	КонецЕсли;
КонецФункции	

Функция ПолучитьСписок(Строка, ИмяПоля) 
	
	Список = Новый Массив;
	
	Если ТипЗнч(Строка[ИмяПоля]) = Тип("СписокXDTO") Тогда
		Для каждого ЭлементСписка Из Строка[ИмяПоля] Цикл 
			Список.Добавить(ЭлементСписка);
		КонецЦикла;
	Иначе		
		Список.Добавить(Строка[ИмяПоля]);
	КонецЕсли;	
	
	Возврат Список;
	
КонецФункции	

Функция ПолучитьДоговор(ПараметрыПоискаДоговора, ТекстЛога)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	ДоговорыКонтрагентов.ПометкаУдаления = ЛОЖЬ
	|	И ДоговорыКонтрагентов.ВалютаВзаиморасчетов = &ВалютаВзаиморасчетов
	|	И ДоговорыКонтрагентов.гф_ДатаНачалаИспользованияДоговораПриЗагрузкеДанных <= &ДатаДокумента
	|	И ДоговорыКонтрагентов.гф_ДатаОкончанияИспользованияДоговораПриЗагрузкеДанных >= &ДатаДокумента
	|	И ДоговорыКонтрагентов.Контрагент = &Контрагент
	// ++ Галфинд_ДомнышеваКР_03_02_2023
	|	И ДоговорыКонтрагентов.ТипДоговора = &ТипДоговора"; 
	// -- Галфинд_ДомнышеваКР_03_02_2023
	
	Запрос.УстановитьПараметр("ВалютаВзаиморасчетов", ПараметрыПоискаДоговора.ВалютаДоговора);
	Запрос.УстановитьПараметр("ДатаДокумента", ПараметрыПоискаДоговора.ДатаДокумента);
	Запрос.УстановитьПараметр("Контрагент", ПараметрыПоискаДоговора.Контрагент);
	// ++ Галфинд_ДомнышеваКР_03_02_2023
	Запрос.УстановитьПараметр("ТипДоговора", Перечисления.ТипыДоговоров.Импорт);
	// -- Галфинд_ДомнышеваКР_03_02_2023
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	Если Результат.Количество() = 1 Тогда
		Возврат Результат[0].Ссылка;
	Иначе
		ТекстЛога = ТекстЛога + Символы.ПС + "Договор не найден или найдено несколько записей"; 
		Возврат Справочники.ДоговорыКонтрагентов.ПустаяСсылка();
	КонецЕсли;		
	
КонецФункции	

// #wortmann { 
// Переводит параметр в таблицу значений 
// Галфинд_Домнышева 2022/10/14
//
// Параметры:
//	СписокXDTO - СписокXDTO или ОбъектXDTO
//
// Возвращаемое значение:
//	ТаблицаЗначений - ТаблицаЗначений 
//
// BSLLS:LatinAndCyrillicSymbolInWord-off
Функция СписокXDTOВТаблицу(СписокXDTO)
// BSLLS:LatinAndCyrillicSymbolInWord-on	
	ТаблицаЗначений = Новый ТаблицаЗначений;

	Если  ТипЗнч(СписокXDTO) = Тип("СписокXDTO") Тогда
		
		Если СписокXDTO.Количество() > 0 тогда
			
			Для каждого Строка из СписокXDTO[0].Свойства() цикл
				
				ТаблицаЗначений.Колонки.Добавить(Строка.Имя);
				
			КонецЦикла;
			
		КонецЕсли;
		
		Для каждого Строка из СписокXDTO цикл
			
			НоваяСтрока = ТаблицаЗначений.Добавить();
			
			Для каждого Колонка из ТаблицаЗначений.Колонки цикл
				
				НоваяСтрока[Колонка.Имя] = Строка[Колонка.Имя];    
				
			КонецЦикла;
			
		КонецЦикла;
		
	Иначе
		Для каждого Строка Из СписокXDTO.Свойства() Цикл
			
			ТаблицаЗначений.Колонки.Добавить(Строка.Имя);
			
		КонецЦикла;	
		
		НоваяСтрока = ТаблицаЗначений.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СписокXDTO); 
		
	КонецЕсли;

	Возврат ТаблицаЗначений;	
КонецФункции// } #wortmann	

Функция ПеревестиСтруктуруВТаблицу(МассивШипЛистов)
	
	ТаблицаШипЛистов = Новый ТаблицаЗначений;
	ТаблицаШипЛистов.Колонки.Добавить("ПолныПутьШипЛиста");
	ТаблицаШипЛистов.Колонки.Добавить("ИмяФайлаШипЛист");
	ТаблицаШипЛистов.Колонки.Добавить("shipping_unit_no");	
	ТаблицаШипЛистов.Колонки.Добавить("АдресШипЛиста");
	ТаблицаШипЛистов.Колонки.Добавить("ИнвойсЕсть");	 
	
	Для каждого Структура Из МассивШипЛистов Цикл
		
		НоваяСтрока =  ТаблицаШипЛистов.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Структура);
		
	КонецЦикла;	
	
	Возврат ТаблицаШипЛистов;
	
КонецФункции

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
	
	КаталогНаДиске = Новый Файл(КудаКопируем);
	Если НЕ КаталогНаДиске.Существует() Тогда
		СоздатьКаталог(КудаКопируем);
	КонецЕсли;
  	
	КаталогЗагруженных = Новый Файл(КудаКопируем);
	Если Не КаталогЗагруженных.Существует() Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Каталог для загруженных файлов задан неверно или не существует.");
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	Для каждого Файл Из ФайлыВАрхив Цикл
		ПереместитьФайл(Файл.ПолноеИмя, КудаКопируем + "\" + Файл.Имя + ".xml");
	КонецЦикла;
	
КонецПроцедуры// } #wortmann 

#КонецОбласти	
	
#КонецЕсли