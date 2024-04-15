﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ПериодВыборки.ДатаОкончания = ТекущаяДатаСеанса();
	ПериодВыборки.ДатаНачала = ДобавитьМесяц(ПериодВыборки.ДатаОкончания, -1); 

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПолучитьИзХранилища(Команда)
	
	ПолучитьОбъектыМетаданных();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьОбъекты(Команда)
	
	Результат = СтрРазделить(ОбъектыХранилища, Символы.ПС, Ложь);
	
	Закрыть(Результат);

КонецПроцедуры

#КонецОбласти
	
#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПолучитьОбъектыМетаданных() 
	
	ИмяРесурса = СтрШаблон("%1?Repository=%2", "MetadataObjects", ПутьКХранилищу);
	
	Если ЗначениеЗаполнено(ПериодВыборки.ДатаНачала) Тогда
		ИмяРесурса = СтрШаблон("%1&PeriodBegin=%2", ИмяРесурса, Формат(ПериодВыборки.ДатаНачала, "ДФ=yyyyMMdd"));
	КонецЕсли;
	Если ЗначениеЗаполнено(ПериодВыборки.ДатаОкончания ) Тогда
		ИмяРесурса = СтрШаблон("%1&PeriodEnd=%2", ИмяРесурса, Формат(ПериодВыборки.ДатаОкончания , "ДФ=yyyyMMdd"));
	КонецЕсли; 
	
	ПолученныеДанные = ВызватьHTTPМетод(ИмяРесурса, "GET");
	Если ЗначениеЗаполнено(ПолученныеДанные) Тогда
		
		ОбъектыХранилища = СтрСоединить(ПолученныеДанные.ОбъектыМетаданных, Символы.ПС);
		
	КонецЕсли;
		
КонецПроцедуры 

&НаКлиенте
Функция ПараметрыСоединения()
	
	Результат = Новый Структура;
	Результат.Вставить("Сервер",       "mail.gf-fin.ru");
	Результат.Вставить("Порт",         8888);
	Результат.Вставить("Пользователь", "hs");
	Результат.Вставить("Пароль",       "Momajo6");
	
	Возврат Результат; 
	
КонецФункции

&НаКлиенте
Функция АдресРесурса(ИмяРесурса)
	
	АдресРесурса = СтрШаблон("/%1/%2/%3/%4", "GitConverter_01", "hs", "Repository", ИмяРесурса);
	
	Возврат АдресРесурса;
	
КонецФункции

&НаКлиенте
Функция ВызватьHTTPМетод(ИмяРесурса, ИмяМетода, ДанныеЗапроса = Неопределено)
	
	ПараметрыСоединения = ПараметрыСоединения();
	
	АдресРесурса = АдресРесурса(ИмяРесурса);
	
	НачалоСообщения = СтрШаблон("%1 %2", ИмяРесурса, ИмяМетода);
	
	Попытка
		
		HTTPСоединение = Новый HTTPСоединение(ПараметрыСоединения["Сервер"], ПараметрыСоединения["Порт"],
			ПараметрыСоединения["Пользователь"], ПараметрыСоединения["Пароль"], , 64);
		
		HTTPЗапрос = Новый HTTPЗапрос(АдресРесурса);
		
		Если ЗначениеЗаполнено(ДанныеЗапроса) Тогда
		
			ТелоЗапросаСтрокой = СтрокаJSONизДанных(ДанныеЗапроса);
		
			HTTPЗапрос.УстановитьТелоИзСтроки(ТелоЗапросаСтрокой, , ИспользованиеByteOrderMark.НеИспользовать);
			
		КонецЕсли;
		
		HTTPОтвет = HTTPСоединение.ВызватьHTTPМетод(ИмяМетода, HTTPЗапрос);
		
		ОтветКодСостояния = HTTPОтвет.КодСостояния;
		
		Если ОтветКодСостояния <> 200 И ОтветКодСостояния <> 204 Тогда
			ТекстСообщения = СтрШаблон("%1: Ошибка КодСостояния = %2", НачалоСообщения, ОтветКодСостояния);
			ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстСообщения);
			Возврат Неопределено;
		КонецЕсли; 
			
		ТелоОтветаСтрокой = HTTPОтвет.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8);
		
		ДанныеОтвета = ДанныеИзСтрокиJSON(ТелоОтветаСтрокой);
		Если ДанныеОтвета.Свойство("Ошибка") Тогда
			
			Если ДанныеОтвета["Ошибка"] Тогда 
				
				ТекстСообщения = СтрШаблон("%1: Ошибка %2", НачалоСообщения, ДанныеОтвета["Примечание"]);
				ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстСообщения);
				Возврат Неопределено;
				
			КонецЕсли;
				
			Возврат ДанныеОтвета["Данные"];
				
		КонецЕсли; 
		
	Исключение
		
		ТекстОшибки = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ТекстСообщения = СтрШаблон("%1: Ошибка %2", НачалоСообщения, ТекстОшибки);
			
		ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстСообщения); 
		
		Возврат Неопределено; 
		
	КонецПопытки;
	
КонецФункции

&НаКлиенте
Функция СтрокаJSONизДанных(Данные) 
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	
	ЗаписатьJSON(ЗаписьJSON, Данные);

	СтрокаJSON = ЗаписьJSON.Закрыть();
	
	Возврат СтрокаJSON;
	
КонецФункции

&НаКлиенте
Функция ДанныеИзСтрокиJSON(СтрокаJSON) 
	
	Если Не ЗначениеЗаполнено(СтрокаJSON) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(СтрокаJSON);
	
	Данные = ПрочитатьJSON(ЧтениеJSON);
	
	ЧтениеJSON.Закрыть();
	
	Если ТипЗнч(Данные) = Тип("Структура") Тогда
		
		Для каждого ЭлементСтруктуры Из Данные Цикл
			
			Если СтрНайти(ВРег(ЭлементСтруктуры.Ключ), "ДАТА") > 0 Тогда
				Попытка
					Данные[ЭлементСтруктуры.Ключ] = ПрочитатьДатуJSON(ЭлементСтруктуры.Значение, ФорматДатыJSON.ISO); 
				Исключение
					Продолжить;
				КонецПопытки;	
			КонецЕсли;
				
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат Данные;
	
КонецФункции

#КонецОбласти