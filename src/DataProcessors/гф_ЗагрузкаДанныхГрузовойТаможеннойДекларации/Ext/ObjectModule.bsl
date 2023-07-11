﻿
Функция СведенияОВнешнейОбработке() Экспорт
	
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке();
	
	ПараметрыРегистрации.Вид				= ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.Версия				= "1.0.0.1";
	ПараметрыРегистрации.БезопасныйРежим	= Ложь;

	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление				= "Загрузка данных таможенной декларации XML";
	НоваяКоманда.Идентификатор				= "ДополнительнаяОбработкаЗагрузкаДанныхТаможеннойДекларацииXML";
	НоваяКоманда.Использование				= ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	НоваяКоманда.ПоказыватьОповещение		= Истина;
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

Процедура ПредварительнаяЗагрузкаФайла(ИмяФайлаОбмена, СтруктураРезультат) Экспорт 
	
	Попытка 
		
		ЧтениеФайла = Новый ЧтениеXML; 
		
		ЧтениеФайла.открытьфайл(ИмяФайлаОбмена); 		
		Фабрика = Новый Фабрикаxdto(); 
		
		Данные = Фабрика.ПрочитатьXML(ЧтениеФайла) ; 
		ТелоГТД = Данные.Получить( "/ContainerDoc/DocBody/ESADout_CU" ) ; 
		СтруктураРезультат.ФорматФайла = ОпределитьФорматФайла (ИмяФайлаОбмена) ;
		
		СтруктураРезультат.НомерГТД = ПолучитьНомерГТД(ИмяФайлаОбмена, СтруктураРезультат.ФорматФайла); 
		
		Если ТелоГТД.esadout_cugoodsshipment.esadout_cuconsignee.свойства().Получить("OrganizationName") <> Неопределено 
			Тогда 
			СтруктураРезультат.Грузополучатель = сокрлп(ТелоГТД.esadout_cugoodsshipment.esadout_cuconsignee.organizationname); 
		ИначеЕсли 
			ТелоГТД.esadout_cugoodsshipment.esadout_cuconsignee.свойства().Получить("DeclarantEqualFlag") <> Неопределено 
			ИЛИ (ТелоГТД.esadout_cugoodsshipment.свойства().Получить("ESADout_CUFinancialAdjustingResponsiblePerson")
			<> Неопределено 
			И 
			ТелоГТД.esadout_cugoodsshipment.esadout_cufinancialadjustingresponsibleperson.свойства().Получить("DeclarantEqualFlag")
			<> Неопределено) Тогда
			СтруктураРезультат.Грузополучатель = сокрлп(ТелоГТД.esadout_cugoodsshipment.esadout_cudeclarant.organizationname); 
		Иначе  
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Ошибка разбора документа: Не определено поле грузополучатель");
			СтруктураРезультат.Результат = Ложь; 
		КонецЕсли;
		
		СтруктураРезультат.Сумма = сокрлп (ТелоГТД.esadout_cugoodsshipment.totalcustcost);
		СтруктураРезультат.Результат = Истина;
		
	Исключение 
		Сообщение = "Ошибка разбора документа:" + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);

		СтруктураРезультат.Результат = Ложь; 
	КонецПопытки;
	
КонецПроцедуры 

Функция ПолучитьДанныеЗаполненияДокументов(ИмяФайлаОбмена, фформа, СтрНомерГТД) Экспорт   
	
	ДанныеЗаполнения = Новый Соответствие; 
	ДанныеЗаполнения.Вставить("ФайлОбработанУспешно", Ложь);
	
	Если ПустаяСтрока(СтрНомерГТД) Тогда  
		СтрНомерГТД = ПолучитьНомерГТД ( ИмяФайлаОбмена , "Не определен");
	КонецЕсли;
	
	Если ПустаяСтрока(СтрНомерГТД) Тогда 
		Возврат ПоместитьВоВременноеХранилище(ДанныеЗаполнения);
	КонецЕсли;
	
	Попытка 
		ЧтениеФайла = Новый ЧтениеXML;
		
		ЧтениеФайла.ОткрытьФайл(ИмяФайлаОбмена);
		
		Фабрика = Новый ФабрикаXDTO();
		Данные = Фабрика.ПрочитатьXML(ЧтениеФайла);

		ТелоГТД = Данные.Получить("/ContainerDoc/DocBody/ESADout_CU"); 
		ДанныеЗаполнения.Вставить("Комментарий", СформироватьКомментарий()) ; 
		ДанныеЗаполнения.Вставить("СоответствиеПлатежей" , ПолучитьСоответствиеПлатежей());
		ДанныеЗаполнения.вставить("ТаможенныеПлатежи", ПолучитьТаможенныеПлатежи(ТелоГТД)); 
		ВалютаДокумента = 
		
					ПолучитьВалюту(ВРег(СокрЛП(ТелоГТД.esadout_cugoodsshipment.esadout_cumaincontractterms.contractcurrencycode)));
		ДанныеЗаполнения.Вставить("ВалютаДокумента", ВалютаДокумента);
		
		Если  ТелоГТД.Свойства().Получить("EECEDocHeaderAddInfo") <> Неопределено Тогда
			Если ТелоГТД.EECEDocHeaderAddInfo.Свойства().Получить("EDocDateTime") <> Неопределено Тогда
			ДатаДокумента = XMLЗначение(тип("Дата"), ТелоГТД.EECEDocHeaderAddInfo.EDocDateTime); 
			КонецЕсли;
		ИначеЕсли ТелоГТД.Свойства().Получить("ExecutionDate") <> Неопределено Тогда
			ДатаДокумента = XMLЗначение(тип("Дата"), ТелоГТД.ExecutionDate); 
		Иначе
			ПозицияПервая = СтрНайти(СтрНомерГТД, "/", НаправлениеПоиска.СНачала);
			ПростоДата = Сред(СтрНомерГТД, ПозицияПервая + 1, 6);
			Год = Лев(ПростоДата, 2);
			Месяц = Сред(ПростоДата, 3, 2);
			День = Прав(ПростоДата, 2);
			ДатаДокумента = Дата("20" + Год, Месяц, День);
		КонецЕсли;
		
		ДанныеЗаполнения.Вставить("ДатаДокумента", ДатаДокумента);
		
		Если ТелоГТД.esadout_cugoodsshipment.esadout_cumaincontractterms.Свойства().Получить("ContractCurrencyRate")
			= Неопределено Тогда  
			СтруктураКурсВалюты = РаботаСКурсамиВалют.ПолучитьКурсВалюты(ВалютаДокумента , ДатаДокумента);
			Курс = СтруктураКурсВалюты.Курс ; 
			ДанныеЗаполнения.Вставить("КурсВзаиморасчетов" , Курс);
		Иначе 
			ЗначениеЧисло = XMLЗначение(тип("Число"), 
			ТелоГТД.esadout_cugoodsshipment.esadout_cumaincontractterms.contractcurrencyrate);
			ДанныеЗаполнения.Вставить("КурсВзаиморасчетов", ЗначениеЧисло); 
		КонецЕсли;
		
		СтранаПроисхождения = ПолучитьСтрануПроисхождения(ВРег(СокрЛП(ТелоГТД.esadout_cugoodsshipment.origincountryname)));
		ДанныеЗаполнения.Вставить("НомерГТД", СтрНомерГТД);
		ДанныеЗаполнения.Вставить("СтранаПроисхождения", СтранаПроисхождения);
		ДанныеЗаполнения.Вставить("Значение_УникальныйИдентификаторИсходногоДокумента", СокрЛП(Данные.documentid));
		
		ДанныеОрганизации = Новый Структура("Наименование, ИНН, КПП");
		
		Если Не ТелоГТД.esadout_cugoodsshipment.esadout_cuconsignee.свойства().Получить("OrganizationName") 
			= Неопределено Тогда  
			ДанныеОрганизации.Наименование = СокрЛП ( ТелоГТД.esadout_cugoodsshipment.esadout_cuconsignee.organizationname);
			ДанныеОрганизации.ИНН = СокрЛП ( ТелоГТД.esadout_cugoodsshipment.esadout_cuconsignee.rforganizationfeatures.inn);
			ДанныеОрганизации.КПП = СокрЛП ( ТелоГТД.esadout_cugoodsshipment.esadout_cuconsignee.rforganizationfeatures.kpp);
		ИначеЕсли 
			Не ТелоГТД.esadout_cugoodsshipment.esadout_cuconsignee.свойства().Получить("DeclarantEqualFlag")
			= Неопределено Тогда
			ДанныеОрганизации.Наименование = СокрЛП ( ТелоГТД.esadout_cugoodsshipment.esadout_cudeclarant.organizationname); 
			ДанныеОрганизации.ИНН = СокрЛП(ТелоГТД.esadout_cugoodsshipment.esadout_cudeclarant.rforganizationfeatures.inn);
		Иначе
			ДанныеОрганизации.Наименование = Неопределено;
			ДанныеОрганизации.ИНН = Неопределено;
		КонецЕсли; 
		
		ДанныеЗаполнения.Вставить("ГТД_ТаможенныйСбор", РасчитатьТаможенныйСбор(ДанныеЗаполнения));
		
		ДанныеЗаполнения.Вставить("ГТД_ТаможенныйСборВал", ПолучитьТаможенныйСборВал(ДанныеЗаполнения));
		ДанныеЗаполнения.Вставить("ГТД_ТаможенныйШтраф", ПолучитьТаможенныйШтраф(ДанныеЗаполнения));
		ДанныеЗаполнения.Вставить("ГТД_ТаможенныйШтрафВал", ПолучитьТаможенныйШтрафВал(ДанныеЗаполнения));
		
		//ПТУ_СуммаДокумента = Число(СокрЛП(ТелоГТД.esadout_cugoodsshipment.esadout_cumaincontractterms.totalinvoiceamount));
		//ДанныеЗаполнения.Вставить("ПТУ_СуммаДокумента", ПТУ_СуммаДокумента); 
		РазобратьФайл(ТелоГТД , ДанныеЗаполнения);
		ДанныеЗаполнения.Вставить("ФайлОбработанУспешно", Истина);
		
		Возврат ПоместитьВоВременноеХранилище(ДанныеЗаполнения);
	Исключение 
		Сообщение = "Ошибка разбора документа:" + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
		
		Возврат ПоместитьВоВременноеХранилище(ДанныеЗаполнения);
		
	КонецПопытки;

КонецФункции

Функция ПолучитьНомерГТД(ИмяФайлаОбмена, ФорматФайла ) 
	
	Попытка
		 Если ФорматФайла = "Не определен" Или ФорматФайла = "Альта Софт" Тогда  
			 
			 ЧтениеФайла = Новый  ЧтениеXML; 
			 
			 ЧтениеФайла.ОткрытьФайл(ИмяФайлаОбмена, Новый ПараметрыЧтенияXML( , , , , , , , Ложь)); 
			 Пока ЧтениеФайла.Прочитать() Цикл  
				 Узел = ЧтениеФайла.типузла; 
				 Значение = ЧтениеФайла.значение; 
			 КонецЦикла;
			 
			 Если Узел = ТипУзлаXML.Комментарий Тогда 
				 Возврат СтрЗаменить(СокрЛП(Значение), "ND=", "");
			 КонецЕсли;
			 
		 ИначеЕсли ФорматФайла = "Сигма Софт" Тогда 
			 ЧтениеФайла = Новый чтениеxml ; 
			 ЧтениеФайла.ОткрытьФайл(ИмяФайлаОбмена, Новый ПараметрыЧтенияXML( , , , , , , , Ложь));
			 Пока ЧтениеФайла.Прочитать() Цикл  
				 Узел = ЧтениеФайла.типузла ; 
				 Значение = ЧтениеФайла.Значение ; 
				 Если Узел = ТипУзлаXML.Комментарий Тогда 
					 Если СтрНайти(Значение , "SIGMA-SOFT.ESAD.GN" ) > 0 Тогда 
						 ЧтениеЖСон = Новый ЧтениеJSON; 
						 Попытка 
							 ЧтениеЖСон.УстановитьСтроку(СокрЛП(Значение));
							 Индекс = 0; 
							 СтрНомерГТД = ""; 
							 Пока ЧтениеЖСон.Прочитать() Цикл 
								 Если Индекс = 1 Тогда 
									 СтрНомерГТД = СокрЛП(ЧтениеЖСон.ТекущееЗначение);
								 КонецЕсли; 
								 Если ЧтениеЖСон.ТипТекущегоЗначения = ТипЗначенияJSON.ИмяСвойства 
									 И СокрЛП(ВРег(ЧтениеЖСон.ТекущееЗначение)) = "SIGMA-SOFT.ESAD.GN" Тогда 
									 Индекс = 1 ; 
									 
								 КонецЕсли;
							 КонецЦикла;
							 
							 ЧтениеЖСон.Закрыть();
							 
						 Исключение 
							 Сообщение = "Ошибка разбора комментария ГТД:" 
							 + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
							 ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
						 КонецПопытки; 
						 Возврат СтрНомерГТД ; 
					 КонецЕсли; 
				 КонецЕсли; 
				 КонецЦикла; 
		 ИначеЕсли ФорматФайла = "Предположительно Декларант+" Тогда 
			 ФайлДек = Новый файл(ИмяФайлаОбмена) ; 
			 Если Не ФайлДек.Существует() Тогда
				 Возврат "" ; 
			 КонецЕсли; 
			 СтрНомерГТД = ФайлДек.ИмяБезРасширения; 
			 СтрНомерГТД = СокрЛП(СтрЗаменить(СтрНомерГТД, "gtdout", "")); 
			 СтрНомерГТД = лев (СтрНомерГТД, СтрДлина(СтрНомерГТД) - 13) 
			 + "/" + лев (прав(СтрНомерГТД, 13), 6) + "/" + прав(СтрНомерГТД, 7);
			 Возврат СтрНомерГТД; 
		 КонецЕсли; 
	 Исключение 
		 Сообщение = "Ошибка выбора ГТД:" + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		 
		 ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
		 Возврат "";
	 КонецПопытки ; 
конецфункции

функция ОпределитьФорматФайла (ИмяФайлаОбмена) 
	
	Попытка 
		
		ЧтениеТекста = новый ЧтениеТекста(ИмяФайлаОбмена, Кодировкатекста.utf8); 
		Данные = ЧтениеТекста.Прочитать(); 
		Если СтрНайти(Данные, "<!--ND=" ) > 0 Тогда 
			ФорматФайла = "Альта Софт"; 
		ИначеЕсли СтрНайти(Данные, "SIGMA-SOFT.ESAD.GN" ) > 0 Тогда  
			ФорматФайла = "Сигма Софт"; 
		ИначеЕсли  СтрНайти(ИмяФайлаОбмена, "gtdout") > 0 Тогда 
			ФорматФайла = "Предположительно Декларант+"; 
		Иначе 
			ФорматФайла = "Не определен"; 
		КонецЕсли; 
		ЧтениеТекста.Закрыть(); 
		ЧтениеТекста = "";
		
	Исключение 
		Сообщение = "Ошибка разбора ГТД:" 
							 + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
		
	КонецПопытки; 
	
	Возврат ФорматФайла;

конецфункции

Функция ТипЗначенияТаблицаЗначений(текзначение) 
	
	Возврат ТипЗнч(текзначение) = Тип("ТаблицаЗначений"); 
	
КонецФункции  

Функция ТипЗначенияЧисло(текзначение) 
	
	Возврат ТипЗнч(текзначение) = Тип("Число");
	
КонецФункции
 
Функция ВернутьТипЗначенияСоответствие(текзначение) 
	
	Возврат ТипЗнч(текзначение) = Тип("Соответствие");
	
КонецФункции
 
функция ТипСтрокаТаблицыЗначений(текзначение) 
	
	Возврат ТипЗнч(текзначение) = Тип("СтрокаТаблицыЗначений"); 
	
конецфункции 

функция СформироватьКомментарий()
	
	Комментарий = "Создан загрузкой ГТД " + Формат(ТекущаяДатаСеанса(), "ДЛФ=DT");
	Возврат Комментарий; 
	
конецфункции

Функция РасчитатьТаможенныйСбор(ДанныеЗаполнения) 
	
	ТаможенныйСбор = 0;
	
	ТаможенныеПлатежи = ДанныеЗаполнения.Получить("ТаможенныеПлатежи");
	СоответствиеПлатежей = ДанныеЗаполнения.Получить("СоответствиеПлатежей");
	
	Если ТипЗначенияТаблицаЗначений(ТаможенныеПлатежи) и ВернутьТипЗначенияСоответствие(СоответствиеПлатежей) Тогда  
		КодВалюты  = Константы.ВалютаРегламентированногоУчета.Получить().Код; 
		ТаможенныеПлатежиКопия = ТаможенныеПлатежи.Скопировать() ; 
		
		ТаможенныеПлатежиКопия.Свернуть ("КодВалюты,КодПлатежа", "Сумма");
		Для Каждого СтрокаТЗ Из ТаможенныеПлатежиКопия Цикл  
			
			Если СтрокаТЗ.КодВалюты = КодВалюты 
				И СоответствиеПлатежей.Получить(СтрокаТЗ.КодПлатежа) = "1" Тогда  
				ТаможенныйСбор = ТаможенныйСбор + СтрокаТЗ.Сумма; 
			КонецЕсли;
		КонецЦикла; 
		
	КонецЕсли;
	
	Возврат ТаможенныйСбор ; 

КонецФункции   

Функция ПолучитьТаможенныйСборВал(ДанныеЗаполнения) 
	
	ТаможенныйСборВал = 0 ; 
	ТаможенныеПлатежи = ДанныеЗаполнения.Получить("ТаможенныеПлатежи"); 
	СоответствиеПлатежей = ДанныеЗаполнения.Получить("СоответствиеПлатежей");
	
	Если ТипЗначенияТаблицаЗначений ( ТаможенныеПлатежи ) И ВернутьТипЗначенияСоответствие(СоответствиеПлатежей) Тогда  
		КодВалютыБаза = Константы.ВалютаРегламентированногоУчета.Получить().Код; 
		ТаможенныеПлатежиКопия = ТаможенныеПлатежи.Скопировать();
		ТаможенныеПлатежиКопия.Свернуть("КодВалюты,КодПлатежа", "Сумма");
		Для Каждого  СтрокаТЗ Из ТаможенныеПлатежиКопия  Цикл  
			Если СтрокаТЗ.КодВалюты <> КодВалютыБаза и СоответствиеПлатежей.Получить(СтрокаТЗ.кодплатежа) = "1" Тогда  
				ТаможенныйСборВал  = ТаможенныйСборВал + СтрокаТЗ.сумма ; 
			КонецЕсли; 
		КонецЦикла; 
	КонецЕсли;
	
	Возврат ТаможенныйСборВал;
	
КонецФункции

Функция ПолучитьТаможенныйШтраф(ДанныеЗаполнения)

	ТаможенныйШтраф = 0 ; 
	
	ТаможенныеПлатежи = ДанныеЗаполнения.Получить("ТаможенныеПлатежи"); 
	СоответствиеПлатежей = ДанныеЗаполнения.Получить("СоответствиеПлатежей");
	
	Если ТипЗначенияТаблицаЗначений(ТаможенныеПлатежи) И ВернутьТипЗначенияСоответствие(СоответствиеПлатежей) Тогда  
		КодВалютыБаза = Константы.ВалютаРегламентированногоУчета.Получить().Код ;
		ТаможенныеПлатежиКопия = ТаможенныеПлатежи.Скопировать();
		ТаможенныеПлатежиКопия.Свернуть("КодВалюты,КодПлатежа", "Сумма"); 
		Для Каждого СтрокаТЗ из ТаможенныеПлатежиКопия Цикл 
			
			Если СтрокаТЗ.КодВалюты = КодВалютыБаза 
				и СоответствиеПлатежей.Получить(СтрокаТЗ.КодПлатежа) = "2" Тогда  
				ТаможенныйШтраф = ТаможенныйШтраф + СтрокаТЗ.Сумма ; 
			КонецЕсли; 
		КонецЦикла; 
	КонецЕсли;
	
	Возврат ТаможенныйШтраф;
	
КонецФункции

Функция ПолучитьТаможенныйШтрафВал(ДанныеЗаполнения)

	ТаможенныйШтрафВал = 0 ; 
	
	ТаможенныеПлатежи = ДанныеЗаполнения.Получить("ТаможенныеПлатежи"); 
	СоответствиеПлатежей = ДанныеЗаполнения.Получить("СоответствиеПлатежей");
	
	Если ТипЗначенияТаблицаЗначений(ТаможенныеПлатежи) И ВернутьТипЗначенияСоответствие(СоответствиеПлатежей) Тогда  
		КодВалютыБаза = Константы.ВалютаРегламентированногоУчета.Получить().Код ;
		ТаможенныеПлатежиКопия = ТаможенныеПлатежи.Скопировать();
		ТаможенныеПлатежиКопия.Свернуть("КодВалюты,КодПлатежа", "Сумма"); 
		Для Каждого СтрокаТЗ из ТаможенныеПлатежиКопия Цикл 
			
			Если СтрокаТЗ.КодВалюты <>  КодВалютыБаза 
				и СоответствиеПлатежей.Получить(СтрокаТЗ.КодПлатежа) = "2" Тогда  
				ТаможенныйШтрафВал = ТаможенныйШтрафВал + СтрокаТЗ.Сумма ; 
			КонецЕсли; 
		КонецЦикла; 
	КонецЕсли;
	
	Возврат ТаможенныйШтрафВал;
	
КонецФункции 

функция ПолучитьСоответствиеПлатежей()
	
	СоответствиеПлатежей = новый соответствие;
	Первый = 1 ; 
	Второй = 2 ; 
	МакетПлатежей = ЭтотОбъект.ПолучитьМакет("Макет_КлассификаторТаможенныхПлатежей"); 
	
	ШиринаТаблицы = МакетПлатежей.ШиринаТаблицы;
	ВысотаТаблицы = МакетПлатежей.ВысотаТаблицы;
	
	Если ШиринаТаблицы > 0 и ВысотаТаблицы > 0 Тогда 
		Для  Шаг = 1 По  ВысотаТаблицы цикл 
			ВидПлатежа = СокрЛП(МакетПлатежей.Область(Шаг, Первый, Шаг, Первый).Текст);
			Код = сокрлп ( МакетПлатежей.область(Шаг, Второй, Шаг, Второй).Текст);
			Если ЗначениеЗаполнено(ВидПлатежа) И  ЗначениеЗаполнено(Код) Тогда 
				Если ВидПлатежа = "1" или ВидПлатежа = "2" 
					Или  ВидПлатежа = "3" или ВидПлатежа = "4" 
					Тогда  СоответствиеПлатежей.Вставить(Код, ВидПлатежа);
				КонецЕсли;
			КонецЕсли; 
		КонецЦикла; 
	КонецЕсли;
	
	Возврат СоответствиеПлатежей;
	
КонецФункции 

функция ПолучитьТаможенныеПлатежи(ТелоГТД)
	
	ТаможенныеПлатежи = Новый  ТаблицаЗначений;
	
	ТаможенныеПлатежи.Колонки.Добавить("НомерРаздела", Новый ОписаниеТипов("Число")); 
	ТаможенныеПлатежи.Колонки.Добавить("КодВалюты", Новый ОписаниеТипов("Строка"));
	
	ТаможенныеПлатежи.Колонки.Добавить("КодПлатежа", Новый ОписаниеТипов("Строка")); 
	ТаможенныеПлатежи.Колонки.Добавить("КодСтавки", Новый ОписаниеТипов("Строка"));
	ТаможенныеПлатежи.Колонки.Добавить("Ставка", Новый ОписаниеТипов("Число")); 
	ТаможенныеПлатежи.Колонки.Добавить("Сумма", Новый ОписаниеТипов("Число"));
	
	
	Если ТипЗнч(ТелоГТД.esadout_cugoodsshipment.esadout_cugoods) = тип("СписокXDTO") Тогда  
		Для Каждого БлокТоваров из ТелоГТД.esadout_cugoodsshipment.esadout_cugoods Цикл  
			ЗаполнитьПлатежи(БлокТоваров, ТаможенныеПлатежи);
		КонецЦикла; 
	Иначе 
		ЗаполнитьПлатежи(ТелоГТД.esadout_cugoodsshipment.esadout_cugoods, ТаможенныеПлатежи);
	КонецЕсли;
	
	ТаможенныеПлатежи.свернуть ("НомерРаздела,КодВалюты,КодПлатежа,КодСтавки,Ставка", "Сумма");
	
	Возврат ТаможенныеПлатежи;
 
КонецФункции

функция ЗаполнитьПлатежи(БлокТоваров, ТаможенныеПлатежи ) 
	
	Если ТипЗнч(БлокТоваров.esadout_cucustomspaymentcalculation) = Тип("СписокXDTO") Тогда 
		
		Для Каждого  СТРХДТОТотовар из БлокТоваров.esadout_cucustomspaymentcalculation Цикл
			СтрокаПлатежей = ТаможенныеПлатежи.Добавить();
			СтрокаПлатежей.НомерРаздела = XMLЗначение(Тип("Число"), БлокТоваров.goodsnumeric);
			СтрокаПлатежей.КодВалюты = СТРХДТОТотовар.paymentcurrencycode ;
			
			СтрокаПлатежей.КодПлатежа = СТРХДТОТотовар.paymentmodecode; 
			
			Попытка 
				СтрокаПлатежей.КодСтавки = СТРХДТОТотовар.ratetypecode;
			Исключение 
			КонецПопытки;
			
			Попытка 
				СтрокаПлатежей.Ставка = XMLЗначение(Тип("Число"), СТРХДТОТотовар.rate);
			Исключение 
			КонецПопытки;
			СтрокаПлатежей.Сумма = XMLЗначение(Тип("Число"), СТРХДТОТотовар.paymentamount);
			
		КонецЦикла;
		
	Иначе СтрокаПлатежей = ТаможенныеПлатежи.добавить(); 
		СтрокаПлатежей.НомерРаздела = XMLЗначение(Тип("Число"), БлокТоваров.goodsnumeric);
		СтрокаПлатежей.КодВалюты = БлокТоваров.esadout_cucustomspaymentcalculation.paymentcurrencycode;
		Попытка 
			СтрокаПлатежей.КодСтавки = БлокТоваров.esadout_cucustomspaymentcalculation.ratetypecode;
		Исключение 
		КонецПопытки;
		
		Попытка 
			СтрокаПлатежей.Ставка = XMLЗначение(Тип("Число"), БлокТоваров.esadout_cucustomspaymentcalculation.rate); 
		Исключение 
		КонецПопытки;
		
		СтрокаПлатежей.Сумма = XMLЗначение(Тип("Число"), БлокТоваров.esadout_cucustomspaymentcalculation.paymentamount);
		
	КонецЕсли;
	
	Возврат ТаможенныеПлатежи;
	
КонецФункции

функция ПолучитьВалюту (ЗначениеИзХДТО) 
	
	Валюта = Неопределено;	
	
	//Если ПустаяСтрока(ЗначениеИзХДТО) тогда 
		Возврат ОбщегоНазначенияБПВызовСервераПовтИсп.ПолучитьВалютуРегламентированногоУчета();
	//КонецЕсли;
	//
	//Если ЗначениеЗаполнено(ЗначениеИзХДТО) тогда 
	//	ЗапросВалюты = новый Запрос;
	//	
	//	ЗапросВалюты.текст = 
	//	"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
	//	|	Валюты.Ссылка КАК Ссылка
	//	|ИЗ
	//	|	Справочник.Валюты КАК Валюты
	//	|ГДЕ
	//	|	Валюты.Наименование = &Наименование
	//	|	И Валюты.ПометкаУдаления = ЛОЖЬ"; 
	//	
	//	ЗапросВалюты.УстановитьПараметр("Наименование", ЗначениеИзХДТО);
	//	
	//	РезультатЗапроса = ЗапросВалюты.выполнить();
	//	Выборка = РезультатЗапроса.выбрать();
	//	
	//	Если НЕ РезультатЗапроса.Пустой() Тогда  
	//		Выборка.Следующий();  
	//		Валюта = Выборка.ссылка ; 
	//	КонецЕсли; 
	//КонецЕсли; 
	
	//Возврат Валюта ; 
 
конецфункции 

функция ПолучитьСтрануПроисхождения(ЗначениеХДТО , ИскатьПоКодАльфа2 = Ложь)
	
	Если ПустаяСтрока(ЗначениеХДТО) Тогда 
		Возврат Справочники.СтраныМира.Россия; 
	КонецЕсли;
	
	СтранаПроисхождения  = Справочники.СтраныМира.ПустаяСсылка(); 
	Если ЗначениеЗаполнено(ЗначениеХДТО) Тогда  
		Запрос = Новый Запрос ;
		Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
		|	СтраныМира.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.СтраныМира КАК СтраныМира
		|ГДЕ
		|	СтраныМира.ПометкаУдаления = ЛОЖЬ
		|	И СтраныМира.Наименование = &Наименование";
		
		
		Если  ИскатьПоКодАльфа2 Тогда  
			Запрос.Текст = СтрЗаменить(Запрос.Текст , "И СтраныМира.Наименование", "И СтраныМира.КодАльфа2"); 
		КонецЕсли; 
		Запрос.УстановитьПараметр("Наименование", ЗначениеХДТО); 
		
		РезультатЗапроса = Запрос.Выполнить();  
		
		Если НЕ РезультатЗапроса.пустой ( ) тогда 
			Выборка = РезультатЗапроса.Выбрать();
			
			Если Выборка.Следующий() Тогда  
				СтранаПроисхождения = Выборка.Ссылка;
			КонецЕсли; 
		Иначе
			СтранаПроисхождения = Неопределено;
		КонецЕсли; 
		
	КонецЕсли; 
	
	Возврат СтранаПроисхождения;

КонецФункции

Процедура РазобратьФайл(ТелоГТД, ДанныеЗаполнения)
	 
	 ТаблицаРазделыГТД = Документы.ТаможеннаяДекларацияИмпорт.ПустаяСсылка().Разделы.ВыгрузитьКолонки();
	 ТаблицаТоварыГТД = Документы.ТаможеннаяДекларацияИмпорт.ПустаяСсылка().Товары.ВыгрузитьКолонки(); 
	 
	 ТаблицаТоварыГТД.Колонки.Добавить("ВариантКомплектации", 
	 							Новый ОписаниеТипов("СправочникСсылка.ВариантыКомплектацииНоменклатуры"));
	 
	 ТаблицаТоварыГТДКопия = ТаблицаТоварыГТД.СкопироватьКолонки(); 
	 
	 НомераГТД = ДанныеЗаполнения.Получить("НомерГТД");
	 СтранаПроисхождения = ДанныеЗаполнения.Получить("СтранаПроисхождения"); 
	  // ДомнышеваКР_ 23_05_2023
	 // Допишем таблицуКодовМаркировки
	 МассивМаркировокТоваров = Новый Массив;

	 Если ТипЗнч(ТелоГТД.esadout_cugoodsshipment.esadout_cugoods) = Тип("СписокXDTO") Тогда 
		 
		 Для Каждого РазделХДТО Из ТелоГТД.esadout_cugoodsshipment.esadout_cugoods Цикл 
			 
			 РазобратьРазделХДТО(РазделХДТО, ТаблицаРазделыГТД,ТаблицаТоварыГТД, 
			 ТаблицаТоварыГТДКопия, СтранаПроисхождения, ДанныеЗаполнения);
			 ЗаполнитьМаркировкиТоваров(РазделХДТО, МассивМаркировокТоваров);
		 КонецЦикла; 
	 Иначе  РазобратьРазделХДТО(ТелоГТД.esadout_cugoodsshipment.esadout_cugoods, 
		 ТаблицаРазделыГТД, ТаблицаТоварыГТД, ТаблицаТоварыГТДКопия, СтранаПроисхождения, ДанныеЗаполнения);
		 ЗаполнитьМаркировкиТоваров(ТелоГТД.esadout_cugoodsshipment.esadout_cugoods, МассивМаркировокТоваров);
	 КонецЕсли; 
	 
	 ДанныеЗаполнения.Вставить("ГТД_Разделы", ТаблицаРазделыГТД); 
	 
	 ДанныеЗаполнения.Вставить("ГТД_Товары", ТаблицаТоварыГТД);
	 // ДомнышеваКР_ 23_05_2023
	 // Допишем таблицуКодовМаркировки
	 ДанныеЗаполнения.Вставить("ГТД_Маркировки", МассивМаркировокТоваров);
	 // ДомнышеваКР_ 23_05_2023
	 
 КонецПроцедуры 
 
Процедура ЗаполнитьМаркировкиТоваров(РазделХДТО, МассивМаркировокТоваров) 
	
	ТелоМаркировок = РазделХДТО.DTIdentificationMeansDetails.IdentificationMeansDetails.IdentificationMeansListDetails.IdentificationMeansItemDetails.IdentificationMeansDataUnitDetails;
	Если ТипЗнч(ТелоМаркировок) = Тип("СписокXDTO") Тогда  
		Для Каждого СтрокаХДТО Из ТелоМаркировок Цикл  
			Если   Лев(СтрокаХДТО.IdentifacationMeansUnitCharacterValueId, 1) <> "("  Тогда
				Маркировка = "(" + Лев(СтрокаХДТО.IdentifacationMeansUnitCharacterValueId, 2) + ")"
				+ Сред(СтрокаХДТО.IdentifacationMeansUnitCharacterValueId, 3, 14) + "(" 
				+ Сред(СтрокаХДТО.IdentifacationMeansUnitCharacterValueId, 17, 2) + ")" 
				+ Сред(СтрокаХДТО.IdentifacationMeansUnitCharacterValueId, 19);
			Иначе
				Маркировка = СтрокаХДТО.IdentifacationMeansUnitCharacterValueId;
			КонецЕсли;
			МассивМаркировокТоваров.Добавить(Маркировка); 
		КонецЦикла;
		
	Иначе  
		Если   Лев(ТелоМаркировок.IdentifacationMeansUnitCharacterValueId, 1) <> "("  Тогда
			Маркировка = "(" + Лев(ТелоМаркировок.IdentifacationMeansUnitCharacterValueId, 2) + ")"
			+ Сред(ТелоМаркировок.IdentifacationMeansUnitCharacterValueId, 3, 14) + "(" 
			+ Сред(ТелоМаркировок.IdentifacationMeansUnitCharacterValueId, 17, 2) + ")" 
			+ Сред(ТелоМаркировок.IdentifacationMeansUnitCharacterValueId, 19);
		Иначе
			Маркировка = ТелоМаркировок.IdentifacationMeansUnitCharacterValueId;
		КонецЕсли;
		МассивМаркировокТоваров.Добавить(Маркировка);
		
	КонецЕсли; 
	 	 
КонецПроцедуры

Процедура РазобратьРазделХДТО(РазделХДТО, ТаблицаРазделыГТД, ТаблицаТоварыГТД, 
	 ТаблицаТоварыГТДКопия, СтранаПроисхождения, ДанныеЗаполнения) 
	 
	 ТаблицаТоварыГТДКопия.Очистить(); 
	 
	 Если ТипЗнч(РазделХДТО.goodsdescription) = Тип("СписокXDTO") Тогда  
		 СтрокаТоворовХДТО = СокрЛП(РазделХДТО.goodsdescription[0]);
	 Иначе  
		 СтрокаТоворовХДТО = СокрЛП(РазделХДТО.goodsdescription); 
	 КонецЕсли; 
	 
	 Раздел = XMLЗначение(Тип("Число"), РазделХДТО.goodsnumeric); 
	 
	 Если ЭтотОбъект.СтоимостьБратьИз = 1 тогда 
		 //КурсВзаиморасчетов = ДанныеЗаполнения.Получить("КурсВзаиморасчетов"); 
		 
		 ТаможеннаяСтоимость = XMLЗначение(Тип("Число"), РазделХДТО.customscost);
	 Иначе  
		 ТаможеннаяСтоимость = XMLЗначение(Тип("Число"), РазделХДТО.invoicedcost) ;
		  КурсВзаиморасчетов = ДанныеЗаполнения.Получить("КурсВзаиморасчетов");
		 	 ТаможеннаяСтоимость = XMLЗначение(Тип("Число"), РазделХДТО.invoicedcost * КурсВзаиморасчетов);

	 КонецЕсли;
	 
	 ТаможеннаяСтоимость = Окр(ТаможеннаяСтоимость, 2);
	 
	 Попытка 
		 ТНВЭКод = СокрЛП(РазделХДТО.goodstnvedcode ) ; 
	 Исключение 
		 ТНВЭКод = "" ; 
	 КонецПопытки;
	 
	 СтранаПроисхожденияСсылка = Справочники.СтраныМира.ПустаяСсылка();
	 
	 Если Не РазделХДТО.Свойства().Получить("OriginCountryCode") = Неопределено Тогда
		 
		 СтранаПроисхожденияСсылка = ПолучитьСтрануПроисхождения( СокрЛП(ВРег(РазделХДТО.origincountrycode)), Истина); 
		 
	 КонецЕсли;
	 
	 Если Не (СтранаПроисхожденияСсылка = Справочники.СтраныМира.ПустаяСсылка()
		 Или  СтранаПроисхожденияСсылка = Справочники.СтраныМира.Россия) Тогда  
		 СтранаПроисхождения  = СтранаПроисхожденияСсылка; 
	 КонецЕсли;
	 
	 Если ТипЗнч(РазделХДТО.goodsgroupdescription) = Тип("СписокXDTO") Тогда
		 
		 Для Каждого СтрокаХДТО Из РазделХДТО.goodsgroupdescription Цикл  
			 РазобратьВеткуХДТО(СтрокаХДТО, ТаблицаТоварыГТДКопия, СтрокаТоворовХДТО, СтранаПроисхождения, Раздел); 
		 КонецЦикла;
		 
	 Иначе  
		 РазобратьВеткуХДТО(РазделХДТО.goodsgroupdescription, 
		 ТаблицаТоварыГТДКопия, СтрокаТоворовХДТО, СтранаПроисхождения, Раздел); 
	 КонецЕсли;
	 
	 ПересчетСтоимостиТоваровГТД(ТаблицаТоварыГТДКопия, ТаможеннаяСтоимость);
	 
	 Для Каждого СтрокаТЗ из ТаблицаТоварыГТДКопия цикл 
	     НоваяСтрокаТоваровГТД = ТаблицаТоварыГТД.Добавить(); 
	     ЗаполнитьЗначенияСвойств(НоваяСтрокаТоваровГТД, СтрокаТЗ); 
	 КонецЦикла;
	 
	 СтрокаРазделаГТД = ТаблицаРазделыГТД.Добавить(); 
	 
	 СтрокаРазделаГТД.НомерСтроки = Раздел ; 
	 СтрокаРазделаГТД.НомерРаздела = Раздел ; 
	 
	 СтрокаРазделаГТД.ТаможеннаяСтоимость = ТаможеннаяСтоимость ;
	 СтрокаРазделаГТД.СтранаПроисхождения = СтранаПроисхождения ;
	 
	 ЗаполнитьПлатежиИПошлины(СтрокаРазделаГТД, ДанныеЗаполнения); 
	 
КонецПроцедуры

Процедура РазобратьВеткуХДТО(СтрокаХДТО, ТаблицаТоварыГТДКопия, 
	СтрокаТоворовХДТО, СтранаПроисхождения, Раздел) 
	 
	 Если ТипЗнч(СтрокаХДТО.goodsdescription) = Тип("СписокXDTO") Тогда  
		 ОписаниеТоваров = "" ; 
		 Для Каждого СтрХДТОТовар из СтрокаХДТО.goodsdescription цикл 
			 ОписаниеТоваров = ОписаниеТоваров + " " + СокрЛП(СтрХДТОТовар) ; 
		 КонецЦикла; 
	 Иначе  
		 ОписаниеТоваров = СокрЛП(СтрокаХДТО.goodsdescription);
	 КонецЕсли; 
	 
	 Если Не (СтрокаХДТО.Свойства().Получить("GoodsGroupInformation") = Неопределено ) Тогда  
		 
		 Если ТипЗнч(СтрокаХДТО.goodsgroupinformation ) = Тип("СписокXDTO") Тогда  
			 Для Каждого СтрХДТОТовар из СтрокаХДТО.goodsgroupinformation цикл 
				 РазборИнформацииПоТоварам(СтрХДТОТовар, ТаблицаТоварыГТДКопия, 
				 СтрокаТоворовХДТО, СтранаПроисхождения, Раздел, ОписаниеТоваров); 
			 КонецЦикла; 
		 Иначе  
			 РазборИнформацииПоТоварам(СтрокаХДТО.goodsgroupinformation, ТаблицаТоварыГТДКопия, 
			 СтрокаТоворовХДТО, СтранаПроисхождения, Раздел, ОписаниеТоваров); 
			 
		 КонецЕсли;
		 
	 КонецЕсли;
	 
КонецПроцедуры

Процедура РазборИнформацииПоТоварам(СтрХДТОТовар, ТаблицаТоварыГТДКопия, 
	СтрокаТоворовХДТО, СтранаПроисхождения, Раздел, ОписаниеТоваров) 
	
	КоличествоУпаковок = XMLЗначение(Тип("Число"), СтрХДТОТовар.goodsgroupquantity.goodsquantity); 
	Номенклатура = ПолучитьНоменклатуру(СтрХДТОТовар, СтрокаТоворовХДТО, ОписаниеТоваров);
	
	ВариантКомплектации = ПолучитьВариантКомплектации(СтрХДТОТовар);
	
	Упаковка = ПолучитьУпаковку(СтрХДТОТовар, Номенклатура) ;
	
	СтрокаТоваровГТД = ТаблицаТоварыГТДКопия.Добавить(); 
	
	СтрокаТоваровГТД.КоличествоУпаковок = КоличествоУпаковок;
	СтрокаТоваровГТД.Количество = КоличествоУпаковок;
	СтрокаТоваровГТД.Упаковка = Упаковка;
	СтрокаТоваровГТД.Номенклатура = Номенклатура;
	
	СтрокаТоваровГТД.ВариантКомплектации = ВариантКомплектации; 
	
	СтрокаТоваровГТД.НомерРаздела = Раздел;
	СтрокаТоваровГТД.СтранаПроисхождения = СтранаПроисхождения; 
	СтрокаТоваровГТД.Суммандс = 0; 
	СтрокаТоваровГТД.СуммаПошлины = 0;
	
	СтрокаТоваровГТД.ТаможеннаяСтоимость = 0; 
	СтрокаТоваровГТД.СтранаПроисхождения = СтранаПроисхождения; 
	
КонецПроцедуры

Функция ПолучитьУпаковку(СтрХДТОТовар, Номенклатура) 
	
	Упаковка = Справочники.УпаковкиЕдиницыИзмерения.НайтиПоНаименованию("шт"); 
	
	//НаименовниеБазовойЕдиницы = СокрЛП(СтрХДТОТовар.goodsgroupquantity.measureunitqualifiername); 
	
	Если ЗначениеЗаполнено(Номенклатура) Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	Номенклатура.ЕдиницаИзмерения КАК ЕдиницаИзмерения
		|ИЗ
		|	Справочник.Номенклатура КАК Номенклатура
		|ГДЕ
		|	Номенклатура.Ссылка = &Ссылка";
		
		Запрос.УстановитьПараметр("Ссылка", Номенклатура);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		Если Не РезультатЗапроса.Пустой() Тогда
			Выборка = РезультатЗапроса.Выбрать();
			
			Выборка.Следующий();		
			Упаковка = Выборка.ЕдиницаИзмерения; 
		КонецЕсли; 
	КонецЕсли;
	
	Возврат Упаковка;
 
конецфункции 

Функция ПолучитьВариантКомплектации(СтрХДТОТовар)

	Если Не (СтрХДТОТовар.Свойства().Получить("GoodsMarking") = Неопределено) 
		Тогда Вариант = сокрлп ( СтрХДТОТовар.goodsmarking) 
	Иначе 
		Вариант = "" ; 
	КонецЕсли; 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВариантыКомплектацииНоменклатуры.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ВариантыКомплектацииНоменклатуры КАК ВариантыКомплектацииНоменклатуры
	|ГДЕ
	|	ВариантыКомплектацииНоменклатуры.Наименование = &Наименование";
	
	Запрос.УстановитьПараметр("Наименование", Вариант);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		
		Выборка.Следующий();
		
		Возврат Выборка.Ссылка;
		
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не найден вариант комплектации " + Вариант);
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции

функция ПолучитьНоменклатуру(СтрХДТОТовар, СтрокаТоворовХДТО, ОписаниеТоваров) 
	
	Номенклатура = Справочники.Номенклатура.ПустаяСсылка();
	
	Если Не (СтрХДТОТовар.свойства().Получить("GoodsMarking") = Неопределено) Тогда  
		Артикул = сокрлп(СтрХДТОТовар.goodsmarking); 
	Иначе 
		Артикул = ""; 
	КонецЕсли;
	
	Если Не  (СтрХДТОТовар.свойства().Получить("GoodsMark") = Неопределено) Тогда
		МаркаТовара = сокрлп(СтрХДТОТовар.goodsmark);
	Иначе  
		МаркаТовара = ""; 
	КонецЕсли;
	
	Если Не (СтрХДТОТовар.свойства().Получить("GoodsModel") = Неопределено) Тогда 
		МодельТовара = сокрлп(СтрХДТОТовар.goodsmodel); 
	Иначе МодельТовара  = "";
	КонецЕсли;
	
	Описание = СокрЛП(ОписаниеТоваров);
	
	Если не ЗначениеЗаполнено(Описание ) Или Описание = ":" Тогда 
		Описание = СокрЛП(СтрокаТоворовХДТО); 
	конецЕсли ; 
	
	Описание = СокрЛП(Описание) + " " + МаркаТовара; 
	
	Описание = СокрЛП(Описание) + " " + МодельТовара; 
	Описание = Лев(СокрЛП(Описание), 1000); 
	
	Если ЗначениеЗаполнено(Описание) Тогда  
		Запрос = Новый  запрос ; 
		
		Запрос.текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
		|	Номенклатура.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Номенклатура КАК Номенклатура
		|ГДЕ
		|	Номенклатура.ПометкаУдаления = ЛОЖЬ
		|	И Номенклатура.НаименованиеПолное = &НаименованиеПолное"; 
		
		Если  ЭтотОбъект.ПоискНоменклатурыПоАртикулу И НЕ ПустаяСтрока(Артикул) Тогда 
			Запрос.Текст = стрзаменить (Запрос.Текст , "НаименованиеПолное", "Артикул"); 
			
			Запрос.УстановитьПараметр("Артикул", Лев(Артикул, СтрДлина(Артикул) - 4));
			
		Иначе  
			Запрос.установитьпараметр("НаименованиеПолное", Описание); 
		КонецЕсли;
		
		РезультатЗапроса = Запрос.Выполнить(); 
		
		Если Не  РезультатЗапроса.Пустой() Тогда  
			Выборка = РезультатЗапроса.Выбрать();
			Выборка.следующий();  
			Номенклатура = Выборка.Ссылка;
		КонецЕсли; 
		
	КонецЕсли;
	
	Возврат Номенклатура ; 
	
конецфункции 

функция НайтиНомерГТД(ЗначениеХДТО, СтранаПроисхождения)

	НомерГТД = Справочники.НомераГТД.ПустаяСсылка(); 
	
	Если ПустаяСтрока(ЗначениеХДТО) 
		Тогда  ЗначениеХДТО = формат(ТекущаяДатаСеанса(),"ДФ=dd/MM/yy/mm/ss") ; 
	КонецЕсли;
	
	Запрос = новый запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
	|	НомераГТД.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.НомераГТД КАК НомераГТД
	|ГДЕ
	|	НомераГТД.ПометкаУдаления = ЛОЖЬ
	|	И НомераГТД.Код = &Код
	|	И НомераГТД.СтранаПроисхождения = &СтранаПроисхождения";
	
	Запрос.УстановитьПараметр("Код", ЗначениеХДТО);
	Запрос.УстановитьПараметр("СтранаПроисхождения", СтранаПроисхождения);
	РезультатЗапроса = Запрос.Выполнить ( ) ;
	
	Если РезультатЗапроса.Пустой() Тогда  
		
		НовыйНомерГТД = Справочники.НомераГТД.СоздатьЭлемент(); 
		НовыйНомерГТД.Код = ЗначениеХДТО;
		НовыйНомерГТД.СтранаПроисхождения = СтранаПроисхождения;
		Попытка 
			НовыйНомерГТД.Записать();
			НомерГТД = НовыйНомерГТД.Ссылка;		
		Исключение 
			Сообщение = "Ошибка записи гтд:" 
							 + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);

		КонецПопытки; 
		
	Иначе  Выборка = РезультатЗапроса.выбрать(); 
		
		Выборка.Следующий();  
		НомерГТД = Выборка.Ссылка; 
		
	КонецЕсли;
	
	Возврат НомерГТД ;
 
КонецФункции

Процедура ПересчетСтоимостиТоваровГТД(ТаблицаТоварыГТДКопия, ТаможеннаяСтоимость) 

	Если ТипЗначенияТаблицаЗначений(ТаблицаТоварыГТДКопия) и ТипЗначенияЧисло(ТаможеннаяСтоимость) Тогда 
		
		Если ТаможеннаяСтоимость > 0 и ТаблицаТоварыГТДКопия.Количество() > 0 Тогда  
			Стоимость = ТаможеннаяСтоимость; 

			Итого = ТаблицаТоварыГТДКопия.Итог("Количество"); 
			
			Если Итого  > 0 Тогда 
				
				Цена = ТаможеннаяСтоимость / Итого;                                               
				
				Для  Каждого СтрокаТЗ из ТаблицаТоварыГТДКопия Цикл  
					СтрокаТЗ.ТаможеннаяСтоимость = Цена * СтрокаТЗ.Количество; 
					Стоимость = Стоимость - СтрокаТЗ.ТаможеннаяСтоимость; 
				КонецЦикла; 
				
				Если Стоимость <> 0 Тогда  
					Количество = 0 ;
					Строка = Неопределено; 
					Для Каждого  СтрокаТЗ Из ТаблицаТоварыГТДКопия Цикл 
						Если СтрокаТЗ.Количество > Количество Тогда  
							Количество = СтрокаТЗ.Количество;
							Строка = СтрокаТЗ; 
						КонецЕсли;
					КонецЦикла;
					
					Если ТипСтрокаТаблицыЗначений(Строка) Тогда  
						
						Строка.ТаможеннаяСтоимость = Строка.ТаможеннаяСтоимость + Стоимость; 
						
					КонецЕсли; 
				КонецЕсли;			
			КонецЕсли; 
		КонецЕсли; 
	КонецЕсли;
	
КонецПроцедуры 

Процедура ЗаполнитьПлатежиИПошлины(СтрокаРазделаГТД, ДанныеЗаполнения) 

	Если ТипСтрокаТаблицыЗначений(СтрокаРазделаГТД) Тогда  
		 
		 ТаможенныеПлатежи = ДанныеЗаполнения.Получить("ТаможенныеПлатежи"); 
		 СоответствиеПлатежей = ДанныеЗаполнения.Получить("СоответствиеПлатежей");
		 
		 Если ТипЗначенияТаблицаЗначений(ТаможенныеПлатежи) и ВернутьТипЗначенияСоответствие(СоответствиеПлатежей) Тогда  
			 
			 СтруктураОтбора = Новый Структура; 
			 
			 СтруктураОтбора.Вставить("НомерРаздела", СтрокаРазделаГТД.НомерСтроки);
			 
			 СтавкаНДС = Справочники.СтавкиНДС.ПустаяСсылка();
			 
			 СуммаПошлины = 0; 
			 
			 МассивПлатежей = ТаможенныеПлатежи.НайтиСтроки(СтруктураОтбора);
			 
			 Для  Каждого НайденнаяСтрока Из МассивПлатежей Цикл  
				 
				 Если СоответствиеПлатежей.Получить(НайденнаяСтрока.КодПлатежа) = "3" Тогда 
					 
					 СуммаПошлины = СуммаПошлины + НайденнаяСтрока.Сумма;
					 СтавкаПошлины = НайденнаяСтрока.Ставка;
					 
				 КонецЕсли;
				 
				 Если СоответствиеПлатежей.Получить(НайденнаяСтрока.КодПлатежа) = "4" Тогда 
					 
					 СтавкаНДС = ПолучитьСтавкуНДС(НайденнаяСтрока);
					 
					 СуммаНДС = НайденнаяСтрока.Сумма; 
					 
				 КонецЕсли;
				 
			 КонецЦикла;
			 
		 КонецЕсли; 
		 
		 СтрокаРазделаГТД.СуммаПошлины = СуммаПошлины; 
		 СтрокаРазделаГТД.СтавкаПошлины = СтавкаПошлины;
		 СтрокаРазделаГТД.СтавкаНДС = СтавкаНДС; 
		 СтрокаРазделаГТД.СуммаНДС = СуммаНДС;
		
	КонецЕсли;
	 
КонецПроцедуры
 
функция ПолучитьСтавкуНДС(СтрокаТаблицыЗначений) 
	
	СтавкаНДС = Справочники.СтавкиНДС.ПустаяСсылка();

	перечисления.ставкиндс.пустаяссылка ( ) ; 
	
	Если ТипСтрокаТаблицыЗначений (СтрокаТаблицыЗначений) Тогда 
		ТаблицаСтавок = СтрокаТаблицыЗначений.Владелец(); 
		
		Если ТипЗначенияТаблицаЗначений(ТаблицаСтавок) Тогда 
			
			Если ТаблицаСтавок.Колонки.Найти("КодСтавки") <> Неопределено 
				и ТаблицаСтавок.Колонки.Найти("Ставка") <> Неопределено Тогда 
				
				КодСтавки = СокрЛП(СтрокаТаблицыЗначений.КодСтавки); 

				Если КодСтавки = "%" Тогда 
					Ставка = СтрокаТаблицыЗначений.Ставка;
					
					Запрос = Новый Запрос;
					Запрос.Текст = 
					"ВЫБРАТЬ
					|	СтавкиНДС.Ссылка КАК Ссылка
					|ИЗ
					|	Справочник.СтавкиНДС КАК СтавкиНДС
					|ГДЕ
					|	СтавкиНДС.Ставка = &Ставка";
					
					Запрос.УстановитьПараметр("Ставка", Ставка);
					
					РезультатЗапроса = Запрос.Выполнить();
					
					Выборка = РезультатЗапроса.Выбрать();
					
					Если Не РезультатЗапроса.Пустой() Тогда
						Выборка.Следующий();
						
						СтавкаНДС = Выборка.Ссылка;
					КонецЕсли;
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли; 
		
	КонецЕсли; 
	
	Возврат СтавкаНДС ;
	
КонецФункции 
 