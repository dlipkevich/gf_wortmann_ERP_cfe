﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	
	// Параметр Период
	ЗначениеПоиска = Новый ПараметрКомпоновкиДанных("Период");
	парамПериод = Настройки.ПараметрыДанных.НайтиЗначениеПараметра(ЗначениеПоиска);
	парамПериод.Значение = КонецДня(ПериодОтчета.ДатаОкончания);
	парамПериод.Использование = Истина;
	
	//Список приобретений
	СписокВыбранныхПТУ = новый СписокЗначений;
	Для каждого Строка Из СписокДоступныхПоступлений цикл
		
		Если Строка.Использовать тогда
			СписокВыбранныхПТУ.Добавить(Строка.СсылкаНаДокумент)
		КонецЕсли;
		
	КонецЦикла; 
	
	ЗначениеПоиска = Новый ПараметрКомпоновкиДанных("ПТУ");
	парамПТУ = Настройки.ПараметрыДанных.НайтиЗначениеПараметра(ЗначениеПоиска);
	парамПТУ.Значение = СписокВыбранныхПТУ;
	парамПТУ.Использование = Истина;
	
	//Отбор по статусам GTIN
	ОтборПоСтатусу = Настройки.Отбор.Элементы.Получить("0");
	ОтборПоСтатусу.ПравоеЗначение = СписокСтатусов;
	ОтборПоСтатусу.Использование = ОтборПоСтатусам;
	Если ВидСравнения = "ВСписке" тогда
		ОтборПоСтатусу.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСписке
	иначе
		ОтборПоСтатусу.ВидСравнения = ВидСравненияКомпоновкиДанных.НеВСписке
	КонецЕсли;
	
	КомпоновщикНастроек.ЗагрузитьНастройки(Настройки);
	
КонецПроцедуры

#КонецЕсли