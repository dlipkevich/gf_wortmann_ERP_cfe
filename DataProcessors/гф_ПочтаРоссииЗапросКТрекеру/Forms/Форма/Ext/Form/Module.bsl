﻿
#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаЗапрос(Команда) 
	
	КомандаЗапросНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура КомандаЗапросНаСервере()   
	
	СтрокаXML = Неопределено;
	
	УчетнаяЗапись	= Объект.УчетнаяЗапись;
	ТрекНомер		= Объект.ТрекНомер;
	
	Ошибки = Новый Массив;
	
	ОтветОтСервера = гф_ПочтаРоссии.ПолучитьДанныеОтслеживания(УчетнаяЗапись, ТрекНомер, Ошибки);
	
	Если Ошибки.Количество() Тогда
		
		Для Каждого Ошибка Из Ошибки Цикл
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Ошибка);
			
		КонецЦикла;	 
		
		Возврат;
		
	КонецЕсли;	    
	
	ОтветМассив = ДанныеОтслеживанияВМассивСтруктур(ОтветОтСервера);
	
	Объект.История.Очистить();
	
	Для Каждого СтрокаОтвета Из ОтветМассив Цикл
		
		НоваяСтрока = Объект.История.Добавить();
		
		НоваяСтрока.ДатаОперации		= СтрокаОтвета.Операция.Дата;
		НоваяСтрока.Операция			= СтрокаОтвета.Операция.Имя;
		НоваяСтрока.ДеталиОперации		= СтрокаОтвета.Операция.Атрибут;
		НоваяСтрока.КонечнаяОперация	= СтрокаОтвета.Операция.КонечнаяОперация;
		
	КонецЦикла;	
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции   

&НаСервере
Функция ОтветОтТрекераСтруктураЗапись()

	Результат = Новый Структура(
	"ПараметрыАдреса,
	|ПараметрыФинансовые,
	|ПараметрыОтправления,
	|Операция,
	|ПараметрыПользователя");
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ДанныеОтслеживанияВМассивСтруктур(ДанныеXDTO)   
	
	Результат = Новый Массив;
	
	Для Каждого Элемент Из ДанныеXDTO.OperationHistoryData.historyRecord Цикл
		
		Запись = ОтветОтТрекераСтруктураЗапись();
		
		Операция = гф_ПочтаРоссии.ОтветОтТрекераСтруктураОперация();  
		
		Операция.Дата		= Элемент.OperationParameters.OperDate;
		Операция.ID			= Элемент.OperationParameters.OperType.id;
		Операция.IDАтрибута	= Элемент.OperationParameters.OperAttr.id;
		
		ДеталиОперации = гф_ПочтаРоссии.ПолучитьДеталиОперацииОтслеживания(Операция.ID, Операция.IDАтрибута);
													
		Операция.Имя				= ДеталиОперации.Имя;
		Операция.Атрибут			= ДеталиОперации.Атрибут;
		Операция.КонечнаяОперация	= ДеталиОперации.КонечнаяОперация;
		
		Запись.Операция = Операция;
		
		Результат.Добавить(Запись);
		
	КонеЦЦикла;              
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

