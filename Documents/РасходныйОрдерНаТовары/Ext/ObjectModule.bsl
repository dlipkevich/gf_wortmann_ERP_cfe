﻿// #wortmann {
// #Монитор логиста
// Запись истории статусов ордеров
// Галфинд Окунев 2022/09/13
&После("ПриЗаписи")
Процедура гф_ПриЗаписи(Отказ)
	
	Если Отказ Тогда
		
		Возврат;
		
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	гф_ИсторияСтатусовРасходныхОрдеровСрезПоследних.Статус КАК Статус
	               |ИЗ
	               |	РегистрСведений.гф_ИсторияСтатусовРасходныхОрдеров.СрезПоследних(, Объект = &Ссылка) КАК гф_ИсторияСтатусовРасходныхОрдеровСрезПоследних
	               |ГДЕ
	               |	гф_ИсторияСтатусовРасходныхОрдеровСрезПоследних.Статус = &Статус";
	
	Запрос.Параметры.Вставить("Ссылка", Ссылка);
	Запрос.Параметры.Вставить("Статус", Статус);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда 
		
		Запись = РегистрыСведений.гф_ИсторияСтатусовРасходныхОрдеров.СоздатьМенеджерЗаписи();
		
		Запись.Период		= ТекущаяДатаСеанса();
		Запись.Активность	= Истина;
		Запись.Объект		= Ссылка;
		Запись.Статус		= Статус;
		
		Запись.Записать();
		
	КонецЕсли;	
	
КонецПроцедуры // } #wortmann