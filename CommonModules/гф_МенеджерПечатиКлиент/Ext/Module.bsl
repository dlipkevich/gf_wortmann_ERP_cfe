﻿#Область ПрограммныйИнтерфейс
 
Функция ПараметрыСпецификацииПоНовойЦене(ПараметрыПечати) Экспорт
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПараметрыСпецификацииПоНовойЦенеПродолжение",
		ЭтотОбъект,
		ПараметрыПечати);
	
	ОткрытьФорму("Документ.гф_СпецификацияПокупателя.Форма.ПараметрыСпецификацииПоНовойЦене", ,
		ПараметрыПечати.Форма, , , ,
		ОписаниеОповещения,
		РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);   
		
	Возврат Истина;	
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Процедура ПараметрыСпецификацииПоНовойЦенеПродолжение(Результат, ПараметрыПечати) Экспорт
	
	Если ЗначениеЗаполнено(Результат) Тогда 
		
		ПараметрыПечати.ДополнительныеПараметры.Вставить("гф_Параметры", Результат);
		
		Форма = ПараметрыПечати.Форма;
		
		ПараметрыПечати.Удалить("Форма");
		
		УправлениеПечатьюКлиент.ВыполнитьКомандуПечати(
			ПараметрыПечати.МенеджерПечати,
			ПараметрыПечати.Идентификатор,
			ПараметрыПечати.ОбъектыПечати,
			Форма,
			ПараметрыПечати);
		
	КонецЕсли;
	
КонецПроцедуры	

#КонецОбласти
