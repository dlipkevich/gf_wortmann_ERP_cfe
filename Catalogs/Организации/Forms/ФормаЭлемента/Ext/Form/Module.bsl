﻿
#Область ОбработчикиСобытийФормы  

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	гф_СоздатьНовыеРеквизиты();
КонецПроцедуры

#КонецОбласти 

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура гф_СоздатьНовыеРеквизиты()
	
	КвалификаторыСтроки	= Новый КвалификаторыСтроки(13);
		
	ОписаниеТиповСтрока 			= Новый ОписаниеТипов("Строка", , КвалификаторыСтроки);

	ДобавляемыеРеквизиты = Новый Массив;
											
	РеквизитФормы_гф_ГЛН_номер		= Новый РеквизитФормы("гф_RC_GLN_номер",
										ОписаниеТиповСтрока, , "GLN_номер", Истина);
		
	ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ГЛН_номер);
	
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	ТипПолеФормы = Тип("ПолеФормы");
		
	НовоеПоле = Элементы.Добавить("гф_RC_GLN_номер", ТипПолеФормы, Элементы.ГруппаОбщаяИнформация);
	
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.гф_RC_GLN_номер";
	
КонецПроцедуры	

#КонецОбласти 