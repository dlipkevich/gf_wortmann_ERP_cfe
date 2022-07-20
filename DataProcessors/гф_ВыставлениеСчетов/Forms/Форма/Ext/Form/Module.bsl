﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Объект.РежимРаботы = 0;
	
	//НастройкаПериода
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаСервере()
	
	ТаблицаСпецификаций.Очистить();;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	гф_СпецификацияПокупателя.Ссылка КАК Ссылка,
	|	гф_СпецификацияПокупателя.Контрагент КАК Контрагент,
	|	гф_СпецификацияПокупателя.Организация КАК Организация,
	|	гф_СпецификацияПокупателя.Договор КАК Договор
	|ПОМЕСТИТЬ втСпецификации
	|ИЗ
	|	Документ.гф_СпецификацияПокупателя КАК гф_СпецификацияПокупателя
	|ГДЕ
	|	гф_СпецификацияПокупателя.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И гф_СпецификацияПокупателя.Договор.гф_Сезон = &Сезон
	|	И гф_СпецификацияПокупателя.Проведен
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втСпецификации.Ссылка КАК Ссылка,
	|	втСпецификации.Контрагент КАК Контрагент,
	|	втСпецификации.Организация КАК Организация,
	|	втСпецификации.Договор КАК Договор
	|ИЗ
	|	втСпецификации КАК втСпецификации,
	|	Документ.гф_СпецификацияПокупателя.ЗаказыКлиентов КАК гф_СпецификацияПокупателяЗаказыКлиентов";
	
	Запрос.УстановитьПараметр("Сезон", Объект.Сезон);
	Запрос.УстановитьПараметр("ДатаНачала", Объект.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", Объект.ДатаОкончания);  
	
	ТзЗапроса = Запрос.Выполнить().Выгрузить();
	ТаблицаСпецификаций.Загрузить(ТзЗапроса); 
	
КонецПроцедуры

&НаКлиенте
Процедура Заполнить(Команда)
	ЗаполнитьНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура СезонПриИзменении(Элемент)
	
	ф = 1;
	
КонецПроцедуры
