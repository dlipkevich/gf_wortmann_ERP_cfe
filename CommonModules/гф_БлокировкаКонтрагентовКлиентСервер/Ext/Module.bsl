﻿  
#Область ПрограммныйИнтерфейс
// #wortmann {
// #Формирование установки блокировки договора с описанием вида блокировки при проведении документа блокировка
// описание вставки
// Галфинд(Просто) Боцманова 2022/09/06
//
// Осуществляет заполненнение данных документа.
//
// Параметры:
//   Источник - ДокументОбъект - Обрабатываемый объект.
//   Отказ - Булево - Признак отказа от записи.
//                   Если в теле процедуры-обработчика установить данному параметру значение Истина,
//                   то запись выполнена не будет и будет вызвано исключение.
//   РежимПроведения - - РежимПроведенияДокумента - В данный параметр передается текущий режим проведения.

Процедура гф_УстановкаБлокировкиДоговоровКонтрагентаОбработкаПроведения1(Источник, Отказ, РежимПроведения) Экспорт
	
	Если ЗначениеЗаполнено(Источник.ДоговорКонтрагента) Тогда 
		
		Если Источник.Заблокирован Тогда 
			ДоговорКонтрагента = Источник.ДоговорКонтрагента;
			ДоговорДляИзменения = ДоговорКонтрагента.ПолучитьОбъект();
			ДоговорДляИзменения.гф_Заблокирован = Истина; 
			Если  НЕ ЗначениеЗаполнено(ДоговорДляИзменения.гф_ОписаниеБлокировки) Тогда
				ДоговорДляИзменения.гф_ОписаниеБлокировки  = Источник.ВидБлокировки;
			Иначе 
				ДоговорДляИзменения.гф_ОписаниеБлокировки  = ДоговорДляИзменения.гф_ОписаниеБлокировки
				+ "; " + Источник.ВидБлокировки;
			КонецЕсли;
			ДоговорДляИзменения.Записать();
		Иначе
			ДоговорКонтрагента = Источник.ДоговорКонтрагента;
		    УстановкаБлокировкиДоговораКонтрагента(ДоговорКонтрагента, Источник);			
		КонецЕсли;
	Иначе
		
		Запрос  =  Новый Запрос;
		Запрос.Текст  =  
		"ВЫБРАТЬ
		|	ДоговорыКонтрагентов.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.Партнер  =  &Контрагент
		|	И ДоговорыКонтрагентов.Организация  =  &Организация";
		Если НЕ Значениезаполнено(Источник.Организация) Тогда
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "И ДоговорыКонтрагентов.Организация  =  &Организация", "");
		КонецЕсли;
		Запрос.УстановитьПараметр("Контрагент", Источник.Контрагент);
		Запрос.УстановитьПараметр("Организация", Источник.Организация);
		
		РезультатЗапроса  =  Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи  =  РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Если Источник.Заблокирован Тогда 
				ДоговорКонтрагента = ВыборкаДетальныеЗаписи.Ссылка;
				ДоговорДляИзменения = ДоговорКонтрагента.ПолучитьОбъект();
				ДоговорДляИзменения.гф_Заблокирован = Истина; 
				Если  НЕ ЗначениеЗаполнено(ДоговорДляИзменения.гф_ОписаниеБлокировки) Тогда
					ДоговорДляИзменения.гф_ОписаниеБлокировки  = Источник.ВидБлокировки;
				Иначе 
					ДоговорДляИзменения.гф_ОписаниеБлокировки  = ДоговорДляИзменения.гф_ОписаниеБлокировки 
					+ "; " + Источник.ВидБлокировки;
				КонецЕсли;
				ДоговорДляИзменения.Записать();
			Иначе
				ДоговорКонтрагента = ВыборкаДетальныеЗаписи.Ссылка;
			    УстановкаБлокировкиДоговораКонтрагента(ДоговорКонтрагента, Источник);				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры   

 #КонецОбласти  
 
#Область ДополнительныеПроцедурыИФункции
 
 Процедура УстановкаБлокировкиДоговораКонтрагента(ДоговорКонтрагента, Источник)
	
	ДоговорДляИзменения = ДоговорКонтрагента.ПолучитьОбъект(); 
	ЗначенияБлокировки  =  СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок
	(ДоговорДляИзменения.гф_ОписаниеБлокировки, "; ");
	Если ЗначенияБлокировки.Количество()  = 1  Тогда
		ДоговорДляИзменения.гф_Заблокирован = Ложь;
		ДоговорДляИзменения.гф_ОписаниеБлокировки  = "";
	Иначе
		ДоговорДляИзменения.гф_ОписаниеБлокировки  = СтрЗаменить
		(ДоговорДляИзменения.гф_ОписаниеБлокировки, Источник.ВидБлокировки , "");
		Если СтрНайти(ДоговорДляИзменения.гф_ОписаниеБлокировки , "; ;") <> 0 Тогда
			ДоговорДляИзменения.гф_ОписаниеБлокировки  = СтрЗаменить(ДоговорДляИзменения.гф_ОписаниеБлокировки , "; ;", ";");
		КонецЕсли;
		Если СтрНайти(ДоговорДляИзменения.гф_ОписаниеБлокировки , "; ") <> 0 Тогда
			ДоговорДляИзменения.гф_ОписаниеБлокировки  = СтрЗаменить(ДоговорДляИзменения.гф_ОписаниеБлокировки , "; " , "");
		КонецЕсли;
			
	КонецЕсли;
	
	ДоговорДляИзменения.Записать();	  
	
КонецПроцедуры

 #КонецОбласти 
 