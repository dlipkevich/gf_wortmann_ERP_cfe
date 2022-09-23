﻿
#Область ОбработчикиСобытий
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ПараметрыОтбора = Параметры.Отбор; 
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	УпаковочныйЛист.Ссылка КАК УпаковочныйЛист
	|ИЗ
	|	Документ.УпаковочныйЛист КАК УпаковочныйЛист
	|ГДЕ
	|	УпаковочныйЛист.Проведен = ИСТИНА
	|	И УпаковочныйЛист.гф_Комплектация = &гф_Комплектация
	|	И УпаковочныйЛист.гф_Заказ = &гф_Заказ"; 
	
	Для каждого ПараметрЗапроса из ПараметрыОтбора Цикл
		Запрос.УстановитьПараметр(ПараметрЗапроса.Ключ, ПараметрЗапроса.Значение );
	КонецЦикла;
	
	ТаблицаУЛ = Запрос.Выполнить().Выгрузить();
	
	УпаковочныеЛисты.Загрузить(ТаблицаУЛ);
	
КонецПроцедуры

#КонецОбласти