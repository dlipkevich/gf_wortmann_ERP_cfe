﻿	
#Область ПрограммныйИнтерфейс

Функция СведенияОВнешнейОбработке() Экспорт
    
    ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке();
    ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиЗаполнениеОбъекта();
    ПараметрыРегистрации.Версия = "2.0";
    ПараметрыРегистрации.Назначение.Добавить("Документ.ЗаказКлиента");
    ПараметрыРегистрации.Назначение.Добавить("Документ.ПеремещениеТоваров");
    ПараметрыРегистрации.Назначение.Добавить("Документ.гф_Скидки");
    ПараметрыРегистрации.Назначение.Добавить("Документ.гф_СпецификацияПокупателя");
    ПараметрыРегистрации.Назначение.Добавить("Документ.ПриобретениеТоваровУслуг");
    ПараметрыРегистрации.Назначение.Добавить("Документ.РеализацияТоваровУслуг");
    ПараметрыРегистрации.Назначение.Добавить("Документ.ПриходныйОрдерНаТовары");
    ПараметрыРегистрации.Назначение.Добавить("Документ.РасходныйОрдерНаТовары");
    ПараметрыРегистрации.Наименование = "Загрузка данных из табличного документа";
    ПараметрыРегистрации.Информация = НСтр("ru='Загрузка данных из табличного документа'");
	ПараметрыРегистрации.БезопасныйРежим = Истина;

    Команда = ПараметрыРегистрации.Команды.Добавить();
    Команда.Идентификатор = "гф_ЗаполнениеДокументовВОРТМАНН";
    Команда.Представление = "Заполнить документ из табличного документа";
    Команда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
    
    Возврат ПараметрыРегистрации;
    
КонецФункции

#КонецОбласти 

	
#Область СлужебныеПроцедуры

Функция ПолучитьМакетОбработки(Имя) Экспорт
	Возврат ПолучитьМакет(Имя);
КонецФункции

#КонецОбласти 
