﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Функция ЗначениеШтрихкодаУникально(Объект) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Справочник.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ШтрихкодыУпаковокТоваров КАК Справочник
	|ГДЕ
	|	Справочник.Ссылка <> &Ссылка
	|	И Справочник.ЗначениеШтрихкода = &ЗначениеШтрихкода";
	
	Запрос.УстановитьПараметр("Ссылка",            Объект.Ссылка);
	Запрос.УстановитьПараметр("ЗначениеШтрихкода", Объект.ЗначениеШтрихкода);

	Возврат Запрос.Выполнить().Пустой();
	
КонецФункции

#КонецЕсли